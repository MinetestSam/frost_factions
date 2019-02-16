tnt = {}

-- Default to enabled when in singleplayer
local enable_tnt = true

-- loss probabilities array (one in X will be lost)
local loss_prob = {}

loss_prob["default:cobble"] = 3
loss_prob["default:dirt"] = 4

local tnt_radius = tonumber(minetest.settings:get("tnt_radius") or 3)

-- Fill a list with data for content IDs, after all nodes are registered
local cid_data = {}
minetest.after(0, function()
	for name, def in pairs(minetest.registered_nodes) do
		cid_data[minetest.get_content_id(name)] = {
			name = name,
			drops = def.drops,
			flammable = def.groups.flammable,
			on_blast = def.on_blast,
		}
	end
end)

local function rand_pos(center, pos, radius)
	local def
	local reg_nodes = minetest.registered_nodes
	local i = 0
	repeat
		-- Give up and use the center if this takes too long
		if i > 4 then
			pos.x, pos.z = center.x, center.z
			break
		end
		pos.x = center.x + math.random(-radius, radius)
		pos.z = center.z + math.random(-radius, radius)
		def = reg_nodes[minetest.get_node(pos).name]
		i = i + 1
	until def and not def.walkable
end

local function eject_drops(drops, pos, radius)
	local drop_pos = vector.new(pos)
	for _, item in pairs(drops) do
		local count = math.min(item:get_count(), item:get_stack_max())
		while count > 0 do
			local take = math.max(1,math.min(radius * radius,
					count,
					item:get_stack_max()))
			rand_pos(pos, drop_pos, radius)
			local dropitem = ItemStack(item)
			dropitem:set_count(take)
			local obj = minetest.add_item(drop_pos, dropitem)
			if obj then
				obj:get_luaentity().collect = true
				obj:setacceleration({x = 0, y = -10, z = 0})
				obj:setvelocity({x = math.random(-3, 3),
						y = math.random(0, 10),
						z = math.random(-3, 3)})
			end
			count = count - take
		end
	end
end

local function add_drop(drops, item)
	item = ItemStack(item)
	local name = item:get_name()
	if loss_prob[name] ~= nil and math.random(1, loss_prob[name]) == 1 then
		return
	end

	local drop = drops[name]
	if drop == nil then
		drops[name] = item
	else
		drop:set_count(drop:get_count() + item:get_count())
	end
end

local basic_flame_on_construct -- cached value
local function destroy(drops, npos, cid, c_air, c_fire,
		on_blast_queue, on_construct_queue,
		ignore_protection, ignore_on_blast, owner)

	local x = npos.x
	local z = npos.z
	local limit = spawnpos
			
	if x < limit.x + 150 and x > limit.x - 150 and z < limit.z + 150 and z > limit.z - 150 then
		return cid
	end

	local def = cid_data[cid]

	if not def then
		return c_air
	elseif not ignore_on_blast and def.on_blast then
		on_blast_queue[#on_blast_queue + 1] = {
			pos = vector.new(npos),
			on_blast = def.on_blast
		}
		return cid
	elseif def.flammable then
		on_construct_queue[#on_construct_queue + 1] = {
			fn = basic_flame_on_construct,
			pos = vector.new(npos)
		}
		return c_fire
	else
		local node_drops = minetest.get_node_drops(def.name, "")
		for _, item in pairs(node_drops) do
			add_drop(drops, item)
		end
		return c_air
	end
end

local function calc_velocity(pos1, pos2, old_vel, power)
	-- Avoid errors caused by a vector of zero length
	if vector.equals(pos1, pos2) then
		return old_vel
	end

	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power)

	-- Divide by distance
	local dist = vector.distance(pos1, pos2)
	dist = math.max(dist, 1)
	vel = vector.divide(vel, dist)

	-- Add old velocity
	vel = vector.add(vel, old_vel)

	-- randomize it a bit
	vel = vector.add(vel, {
		x = math.random() - 0.5,
		y = math.random() - 0.5,
		z = math.random() - 0.5,
	})

	-- Limit to terminal velocity
	dist = vector.length(vel)
	if dist > 250 then
		vel = vector.divide(vel, dist / 250)
	end
	return vel
end

local function entity_physics(pos, radius, drops)
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:get_pos()
		local dist = math.max(1, vector.distance(pos, obj_pos))

		local damage = (4 / dist) * radius
		if obj:is_player() then
			-- currently the engine has no method to set
			-- player velocity. See #2960
			-- instead, we knock the player back 1.0 node, and slightly upwards
			local dir = vector.normalize(vector.subtract(obj_pos, pos))
			local moveoff = vector.multiply(dir, dist + 1.0)
			local newpos = vector.add(pos, moveoff)
			newpos = vector.add(newpos, {x = 0, y = 0.2, z = 0})
			obj:setpos(newpos)

			obj:set_hp(obj:get_hp() - damage)
		elseif obj:get_entity_name() ~= "tnt:tnt_flying" then
			local do_damage = true
			local do_knockback = true
			local entity_drops = {}
			local luaobj = obj:get_luaentity()
			local objdef = minetest.registered_entities[luaobj.name]

			if objdef and objdef.on_blast then
				do_damage, do_knockback, entity_drops = objdef.on_blast(luaobj, damage)
			end

			if do_knockback then
				local obj_vel = obj:getvelocity()
				obj:setvelocity(calc_velocity(pos, obj_pos,
						obj_vel, radius * 10))
			end
			if do_damage then
				if not obj:get_armor_groups().immortal then
					obj:punch(obj, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = damage},
					}, nil)
				end
			end
			for _, item in pairs(entity_drops) do
				add_drop(drops, item)
			end
		else
			local obj_vel = obj:getvelocity()
				obj:setvelocity(calc_velocity(pos, obj_pos,
						obj_vel, radius * 2))
		end
	end
end

local function add_effects(pos, radius, drops)
	minetest.add_particle({
		pos = pos,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 0.4,
		size = radius * 10,
		collisiondetection = false,
		vertical = false,
		texture = "tnt_boom.png",
		glow = 15,
	})
	minetest.add_particlespawner({
		amount = 64,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -10, y = -10, z = -10},
		maxvel = {x = 10, y = 10, z = 10},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius * 3,
		maxsize = radius * 5,
		texture = "tnt_smoke.png",
	})

	-- we just dropped some items. Look at the items entities and pick
	-- one of them to use as texture
	local texture = "tnt_blast.png" --fallback texture
	local most = 0
	for name, stack in pairs(drops) do
		local count = stack:get_count()
		if count > most then
			most = count
			local def = minetest.registered_nodes[name]
			if def and def.tiles and def.tiles[1] then
				texture = def.tiles[1]
			end
		end
	end

	minetest.add_particlespawner({
		amount = 64,
		time = 0.1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -3, y = 0, z = -3},
		maxvel = {x = 3, y = 5,  z = 3},
		minacc = {x = 0, y = -10, z = 0},
		maxacc = {x = 0, y = -10, z = 0},
		minexptime = 0.8,
		maxexptime = 2.0,
		minsize = radius * 0.66,
		maxsize = radius * 2,
		texture = texture,
		collisiondetection = true,
	})
end

function tnt.burn(pos, nodename)
	local name = nodename or minetest.get_node(pos).name
	local def = minetest.registered_nodes[name]
	if not def then
		return
	elseif def.on_ignite then
		def.on_ignite(pos)
	elseif minetest.get_item_group(name, "tnt") > 0 then
		minetest.swap_node(pos, {name = name .. "_burning"})
		minetest.sound_play("tnt_ignite", {pos = pos})
		minetest.get_node_timer(pos):start(1)
	end
end

local function tnt_explode(pos, radius, ignore_protection, ignore_on_blast, owner, explode_center, in_water)
	pos = vector.round(pos)
	-- scan for adjacent TNT nodes first, and enlarge the explosion
	local vm1 = VoxelManip()
	local p1 = vector.subtract(pos, 2)
	local p2 = vector.add(pos, 2)
	local minp, maxp = vm1:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm1:get_data()
	local count = 0
	local c_tnt = minetest.get_content_id("tnt:tnt")
	local c_tnt_burning = minetest.get_content_id("tnt:tnt_burning")
	local c_tnt_boom = minetest.get_content_id("tnt:boom")
	local c_air = minetest.get_content_id("air")
	
	if in_water == nil then
		in_water = false
	end
	
	-- make sure we still have explosion even when centre node isnt tnt related
	if explode_center then
		count = 1
	end

	for z = pos.z - 2, pos.z + 2 do
		for y = pos.y - 2, pos.y + 2 do
			local vi = a:index(pos.x - 2, y, z)
			for x = pos.x - 2, pos.x + 2 do
				local cid = data[vi]
				if cid == c_tnt or cid == c_tnt_boom then
					count = count + 1
					data[vi] = c_air
				end
				vi = vi + 1
			end
		end
	end

	vm1:set_data(data)
	vm1:write_to_map()

	-- recalculate new radius
	radius = math.floor(radius * math.pow(count, 1/3))

	-- perform the explosion
	local vm = VoxelManip()
	local pr = PseudoRandom(os.time())
	p1 = vector.subtract(pos, radius)
	p2 = vector.add(pos, radius)
	minp, maxp = vm:read_from_map(p1, p2)
	a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	data = vm:get_data()

	local drops = {}
	local on_blast_queue = {}
	local on_construct_queue = {}
	basic_flame_on_construct = minetest.registered_nodes["fire:basic_flame"].on_construct

	local c_fire = minetest.get_content_id("fire:basic_flame")
	for z = -radius, radius do
	for y = -radius, radius do
	local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	for x = -radius, radius do
		local r = vector.length(vector.new(x, y, z))
		if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
			local cid = data[vi]
			local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
			if cid ~= c_air and (in_water == false or cid == c_tnt_burning) then
				data[vi] = destroy(drops, p, cid, c_air, c_fire,
					on_blast_queue, on_construct_queue,
					ignore_protection, ignore_on_blast, owner)
			end
		end
		vi = vi + 1
	end
	end
	end

	vm:set_data(data)
	vm:write_to_map()
	vm:update_map()
	vm:update_liquids()

	-- call check_single_for_falling for everything within 1.5x blast radius
	for y = -radius * 1.5, radius * 1.5 do
	for z = -radius * 1.5, radius * 1.5 do
	for x = -radius * 1.5, radius * 1.5 do
		local rad = {x = x, y = y, z = z}
		local s = vector.add(pos, rad)
		local r = vector.length(rad)
		if r / radius < 1.4 then
			minetest.check_single_for_falling(s)
		end
	end
	end
	end

	for _, queued_data in pairs(on_blast_queue) do
		local dist = math.max(1, vector.distance(queued_data.pos, pos))
		local intensity = (radius * radius) / (dist * dist)
		local node_drops = queued_data.on_blast(queued_data.pos, intensity, pos)
		if node_drops then
			for _, item in pairs(node_drops) do
				add_drop(drops, item)
			end
		end
	end

	for _, queued_data in pairs(on_construct_queue) do
		queued_data.fn(queued_data.pos)
	end

	minetest.log("action", "TNT owned by " .. owner .. " detonated at " ..
		minetest.pos_to_string(pos) .. " with radius " .. radius)

	return drops, radius
end

function tnt.boom(pos, def)
	def = def or {}
	def.radius = def.radius or 1
	def.damage_radius = def.damage_radius or def.radius * 2
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if not def.explode_center then
		minetest.set_node(pos, {name = "tnt:boom"})
	end
	minetest.sound_play("tnt_explode", {pos = pos, gain = 1.5, max_hear_distance = 2*64})
	local drops, radius = tnt_explode(pos, def.radius, def.ignore_protection,
			def.ignore_on_blast, owner, def.explode_center, def.in_water)
	-- append entity drops
	local damage_radius = (radius / math.max(1, def.radius)) * def.damage_radius
	entity_physics(pos, damage_radius, drops)
	if not def.disable_drops then
		eject_drops(drops, pos, radius)
	end
	add_effects(pos, radius, drops)
	minetest.log("action", "A TNT explosion occurred at " .. minetest.pos_to_string(pos) ..
		" with radius " .. radius)
end

minetest.register_node("tnt:boom", {
	drawtype = "airlike",
	light_source = default.LIGHT_MAX,
	walkable = false,
	drop = "",
	groups = {dig_immediate = 3},
	-- unaffected by explosions
	on_blast = function() end,
})

minetest.register_node("tnt:gunpowder", {
	description = "Gun Powder",
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	tiles = {
		"tnt_gunpowder_straight.png",
		"tnt_gunpowder_curved.png",
		"tnt_gunpowder_t_junction.png",
		"tnt_gunpowder_crossing.png"
	},
	inventory_image = "tnt_gunpowder_inventory.png",
	wield_image = "tnt_gunpowder_inventory.png",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	groups = {dig_immediate = 2, attached_node = 1, flammable = 5,
		connect_to_raillike = minetest.raillike_group("gunpowder")},
	sounds = default.node_sound_leaves_defaults(),

	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			minetest.set_node(pos, {name = "tnt:gunpowder_burning"})
			minetest.log("action", puncher:get_player_name() ..
				" ignites tnt:gunpowder at " ..
				minetest.pos_to_string(pos))
		end
	end,
	on_blast = function(pos, intensity)
		minetest.set_node(pos, {name = "tnt:gunpowder_burning"})
	end,
	on_burn = function(pos)
		minetest.set_node(pos, {name = "tnt:gunpowder_burning"})
	end,
	on_ignite = function(pos, igniter)
		minetest.set_node(pos, {name = "tnt:gunpowder_burning"})
	end,
})

minetest.register_node("tnt:gunpowder_burning", {
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 5,
	tiles = {{
		name = "tnt_gunpowder_burning_straight_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	},
	{
		name = "tnt_gunpowder_burning_curved_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	},
	{
		name = "tnt_gunpowder_burning_t_junction_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	},
	{
		name = "tnt_gunpowder_burning_crossing_animated.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 1,
		}
	}},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	drop = "",
	groups = {
		dig_immediate = 2,
		attached_node = 1,
		connect_to_raillike = minetest.raillike_group("gunpowder")
	},
	sounds = default.node_sound_leaves_defaults(),
	on_timer = function(pos, elapsed)
		for dx = -1, 1 do
		for dz = -1, 1 do
			if math.abs(dx) + math.abs(dz) == 1 then
				for dy = -1, 1 do
					tnt.burn({
						x = pos.x + dx,
						y = pos.y + dy,
						z = pos.z + dz,
					})
				end
			end
		end
		end
		minetest.remove_node(pos)
	end,
	-- unaffected by explosions
	on_blast = function() end,
	on_construct = function(pos)
		minetest.sound_play("tnt_gunpowder_burning", {pos = pos, gain = 2})
		minetest.get_node_timer(pos):start(1)
	end,
})

minetest.register_craft({
	output = "tnt:gunpowder 5",
	type = "shapeless",
	recipe = {"default:coal_lump", "default:gravel"}
})

if enable_tnt then
	minetest.register_craft({
		output = "tnt:tnt",
		recipe = {
			{"group:wood",    "tnt:gunpowder", "group:wood"},
			{"tnt:gunpowder", "tnt:gunpowder", "tnt:gunpowder"},
			{"group:wood",    "tnt:gunpowder", "group:wood"}
		}
	})

	minetest.register_abm({
		label = "TNT ignition",
		nodenames = {"group:tnt", "tnt:gunpowder"},
		neighbors = {"fire:basic_flame", "default:lava_source", "default:lava_flowing"},
		interval = 4,
		chance = 1,
		action = function(pos, node)
			tnt.burn(pos, node.name)
		end,
	})
end

function tnt.register_tnt(def)
	local name
	if not def.name:find(':') then
		name = "tnt:" .. def.name
	else
		name = def.name
		def.name = def.name:match(":([%w_]+)")
	end
	if not def.tiles then def.tiles = {} end
	local tnt_top = def.tiles.top or def.name .. "_top.png"
	local tnt_bottom = def.tiles.bottom or def.name .. "_bottom.png"
	local tnt_side = def.tiles.side or def.name .. "_side.png"
	local tnt_burning = def.tiles.burning or def.name .. "_top_burning_animated.png"
	if not def.damage_radius then def.damage_radius = def.radius * 2 end

	if enable_tnt then
		minetest.register_node(":" .. name, {
			description = def.description,
			tiles = {tnt_top, tnt_bottom, tnt_side},
			is_ground_content = false,
			groups = {dig_immediate = 2, mesecon = 2, tnt = 1, flammable = 5},
			sounds = default.node_sound_wood_defaults(),
			after_place_node = function(pos, placer)
				if placer:is_player() then
					local meta = minetest.get_meta(pos)
					meta:set_string("owner", placer:get_player_name())
				end
			end,
			on_punch = function(pos, node, puncher)
				if puncher:get_wielded_item():get_name() == "default:torch" then
					minetest.swap_node(pos, {name = name .. "_burning"})
					minetest.registered_nodes[name .. "_burning"].on_construct(pos)
					minetest.log("action", puncher:get_player_name() ..
						" ignites " .. node.name .. " at " ..
						minetest.pos_to_string(pos))
				end
			end,
			on_blast = function(pos, intensity)
				minetest.after(0.1, function()
					minetest.swap_node(pos, {name = name .. "_burning"})
					minetest.registered_nodes[name .. "_burning"].on_construct(pos)
				end)
			end,
			mesecons = {effector =
				{action_on =
					function(pos)
						minetest.swap_node(pos, {name = name .. "_burning"})
						minetest.registered_nodes[name .. "_burning"].on_construct(pos)
					end
				}
			},
			on_burn = function(pos)
				minetest.swap_node(pos, {name = name .. "_burning"})
				minetest.registered_nodes[name .. "_burning"].on_construct(pos)
			end,
			on_ignite = function(pos, igniter)
				minetest.swap_node(pos, {name = name .. "_burning"})
				minetest.registered_nodes[name .. "_burning"].on_construct(pos)
			end,
		})
	end
	
	local c_air = minetest.get_content_id("air")
	local c_water_source = minetest.get_content_id("default:water_source")
	local c_water_flowing = minetest.get_content_id("default:water_flowing")
	local c_lava_source = minetest.get_content_id("default:lava_source")
	local c_lava_flowing = minetest.get_content_id("default:lava_flowing")
	
	minetest.register_entity(name .. "_flying", {
		name = name .. "_flying",
		textures = {
			name .. "_burning"
		},
		timer = 0,
		bomb_timer = 0,
		visual = "wielditem",
		visual_size = {x = 0.667, y = 0.667},
		physical = true,
		is_visible = true,
		collide_with_objects = false,
		meta = {},
		on_step = function(self, dtime)
			self.timer = self.timer + dtime
			self.bomb_timer = self.bomb_timer + dtime
			if self.bomb_timer >= 1.0 then
				local t = self.meta.time
				if t and t < 1 then
					local pos = self.object:get_pos()
					
					local pos1 = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1}
					local pos2 = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1}
					
					local vm = minetest.get_voxel_manip()
					
					local emin, emax = vm:read_from_map(pos2, pos1)
					
					local a = VoxelArea:new{
						MinEdge = emin,
						MaxEdge = emax
					}
				
				local data = vm:get_data()
				
					local vr = vector.round({x = pos.x, y = pos.y, z = pos.z})
					local n0 = data[a:index(vr.x, vr.y, vr.z)]
					if n0 == c_water_source or n0 == c_water_flowing or n0 == c_lava_source or n0 == c_lava_flowing then
						def.in_water = true
					end
					self.object:remove()
					tnt.boom(pos, def)
					def.in_water = false
				else
					if t == nil then
						t = 4
					end
					t = t - 1
					self.meta.time = t
					self.bomb_timer = 0
				end
			end
		end,
		on_blast = function(pos, intensity, blaster)
			return
		end
		})

	minetest.register_node(":" .. name .. "_burning", {
		tiles = {
			{
				name = tnt_burning,
				animation = {
					type = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 1,
				}
			},
			tnt_bottom, tnt_side
			},
		light_source = 5,
		drop = "",
		sounds = default.node_sound_wood_defaults(),
		groups = {},
		on_timer = function(pos, elapsed)
			local meta = minetest.get_meta(pos)
			local mtime = tonumber(meta:get_string("time"))
			if mtime < 1 then
				tnt.boom(pos, def)
			else
				mtime = mtime - 1
				meta:set_string("time", mtime)
				
				local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
				local bcn = minetest.get_node_or_nil(bcp)
				if bcn then
					local bcd = bcn and minetest.registered_nodes[bcn.name]
					
					local node = minetest.get_node(pos)
					
					if (bcd and bcd.buildable_to and
							(minetest.get_item_group(node.name, "float") == 0 or
							bcd.liquidtype == "none")) or bcn == nil then
						local obj = minetest.env:add_entity(pos, name .. "_flying")
						obj:get_luaentity().meta = {time = mtime}
						obj:setacceleration({x = 0, y = -10, z = 0})
						minetest.remove_node(pos)
						return
					end
				end
				return true
			end
		end,
		on_blast = function(pos, intensity, blaster)
			local meta = minetest.get_meta(pos)
			local mtime = tonumber(meta:get_string("time"))
			minetest.remove_node(pos)
			
			local dist = math.max(1.0, vector.distance(blaster, pos))
			local dir = vector.normalize(vector.subtract(pos, blaster))
			local moveoff = vector.multiply(dir, (intensity * 2.0) / dist)
			
			local obj = minetest.env:add_entity(pos, name .. "_flying")
			obj:get_luaentity().meta = {time = mtime}
			obj:setvelocity(moveoff)
			obj:setacceleration({x = 0, y = -10, z = 0})
		end,
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			minetest.sound_play("tnt_ignite", {pos = pos})
			minetest.get_node_timer(pos):start(1.0)
			local meta = minetest.get_meta(pos)
			meta:set_string("time", 4)
			
			local bcp = {x = pos.x, y = pos.y - 0.7, z = pos.z}
			
			local bcn = minetest.get_node_or_nil(bcp)
			if bcn then
				local bcd = bcn and minetest.registered_nodes[bcn.name]
				
				if (bcd and bcd.buildable_to and
						(minetest.get_item_group(node.name, "float") == 0 or
						bcd.liquidtype == "none")) or bcn == nil then
					local obj = minetest.env:add_entity(pos, name .. "_flying")
					obj:get_luaentity().meta = {time = 4}
					obj:setacceleration({x = 0, y = -10, z = 0})
					minetest.remove_node(pos)
					return
				end
			end
		end,
	})
end

tnt.register_tnt({
	name = "tnt:tnt",
	description = "TNT",
	radius = tnt_radius,
})
