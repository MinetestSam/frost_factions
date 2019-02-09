local gravity = -9.81
local charge_speed = 0.5
local arrow_lifetime = 60

minetest.register_tool("bow:wood_bow", {
	description = "Wood Bow",
	inventory_image = "bow_inv.png",
	wield_scale = {x = 2, y = 2, z = 1},
	on_drop = function(itemstack, dropper, pos)
		itemstack:set_name("bow:wood_bow_dropped")
		minetest.item_drop(itemstack, dropper, pos)
		return ""
	end,
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		groupcaps={},
		damage_groups = {},
	},
	range = 4
})

minetest.register_tool("bow:wood_bow_1", {
	description = "Wood Bow",
	inventory_image = "bow_1.png",
	wield_scale = {x = 2, y = 2, z = 1},
	groups = {not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		itemstack:set_name("bow:wood_bow_dropped")
		minetest.item_drop(itemstack, dropper, pos)
		return ""
	end,
	range = 0
})

minetest.register_tool("bow:wood_bow_2", {
	description = "Wood Bow",
	inventory_image = "bow_2.png",
	wield_scale = {x = 2, y = 2, z = 1},
	groups = {not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		itemstack:set_name("bow:wood_bow_dropped")
		minetest.item_drop(itemstack, dropper, pos)
		return ""
	end,
	range = 0
})

minetest.register_tool("bow:wood_bow_3", {
	description = "Wood Bow",
	inventory_image = "bow_3.png",
	wield_scale = {x = 2, y = 2, z = 1},
	groups = {not_in_creative_inventory=1},
	on_drop = function(itemstack, dropper, pos)
		itemstack:set_name("bow:wood_bow_dropped")
		minetest.item_drop(itemstack, dropper, pos)
		return ""
	end,
	range = 0
})

minetest.register_tool("bow:wood_bow_dropped", {
	description = "Wood Bow",
	inventory_image = "bow_inv.png",
	groups = {not_in_creative_inventory=1},
	range = 0
})

minetest.register_craftitem("bow:flint_arrow", {
	description = "Flint Arrow",
	inventory_image = "bow_arrow.png"
})

minetest.register_entity("bow:flint_arrow_ent", {
	physical = true,
	visual = "mesh",
	mesh = "arrow.obj",
	collide_with_objects = false,
	visual_size = { x= 1, y = 1},
    collisionbox = {-0.1,-0.1,-0.1, 0.1,0.1,0.1},
	textures = {"bow_arrow_uv.png"},
	timer = 0,
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if not self.start_timer then self.object:remove() return end
		if not self.charge then self.object:remove() return end
		local pos = self.object:getpos()
		local vel = self.object:getvelocity()
		if ((self.start_vel.x~=0 and vel.x == 0) or (self.start_vel.z ~= 0 and vel.z == 0) or vel.y == 0) and self.charge > 0 then
			self.object:setvelocity({x = 0, y = 0, z = 0})
			self.object:setacceleration({x = 0, y = 0, z = 0})
			self.charge = 0
			self.timer = 0
		end
		if self.charge == 0 and self.timer >= arrow_lifetime then
			self.object:remove()
		elseif self.charge == 0 then
			self.timer = self.timer + dtime
			local objects = minetest.get_objects_inside_radius(pos, 3)
			for _,obj in ipairs(objects) do
				if obj:is_player() then
					local inv = minetest.get_inventory({type = "player", name = obj:get_player_name()})
					inv:add_item("main", "bow:flint_arrow")
					self.object:remove()
				end
			end
		end
		if self.start_timer <= 0.1 then
			self.start_timer = self.start_timer + dtime
		end
		if self.charge > 0 and self.start_timer >= 0.1 then
			local objects = minetest.get_objects_inside_radius(pos, 2)
			for _,obj in ipairs(objects) do
				if obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().name ~= "bow:flint_arrow_ent") then
					obj:punch(self.player, nil, {damage_groups = {fleshy=self.charge*2}}, self.object:getvelocity())
					self.object:remove()
				end
			end
		end
	end
})
local timer = 0
local bow_load={}

controls.register_on_release(function(player, key, time)
	if key~="RMB" then return end
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	if (wielditem:get_name()=="bow:wood_bow_1" or wielditem:get_name()=="bow:wood_bow_2" or wielditem:get_name()=="bow:wood_bow_3") then
		local yaw = player:get_look_yaw()
		local dir = player:get_look_dir()
		local pos = vector.add(player:getpos(), {x=dir.x*2, y=dir.y*2+1.5, z=dir.z*2})
		local obj = minetest.add_entity(pos, "bow:flint_arrow_ent")
		obj:setyaw(yaw + math.pi)
		local charge = 1
		if wielditem:get_name()=="bow:wood_bow_1" then
			charge = 1
		elseif wielditem:get_name()=="bow:wood_bow_2" then
			charge = 2
		elseif wielditem:get_name()=="bow:wood_bow_3" then
			charge = 3
		end
		obj:setvelocity({x=dir.x*charge*18,055566667, y=dir.y*charge*18,055566667, z=dir.z*charge*18,055566667})
		obj:setacceleration({x=0, y=gravity, z=0})
		obj:get_luaentity().charge = charge
		obj:get_luaentity().player = player
		obj:get_luaentity().start_timer = 0
		obj:get_luaentity().start_vel = {x=dir.x*charge*18,055566667, y=dir.y*charge*18,055566667, z=dir.z*charge*18,055566667}
		player:set_physics_override({speed=1})
		wielditem:set_name("bow:wood_bow")
		wielditem:add_wear(charge*100)
		player:set_wielded_item(wielditem)
		inv:remove_item("main", "bow:flint_arrow 1")
		bow_load[player:get_player_name()]=false
		player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
	end
end)

controls.register_on_hold(function(player, key, time)
	if key~="RMB" then return end
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	local wielditem = player:get_wielded_item()
	if wielditem:get_name()=="bow:wood_bow" and inv:contains_item("main", "bow:flint_arrow") then
		player:set_physics_override({speed=0.25})
		wielditem:set_name("bow:wood_bow_1")
		bow_load[player:get_player_name()]=os.time()
	elseif wielditem:get_name()=="bow:wood_bow_1" and os.time()-bow_load[player:get_player_name()]>charge_speed then
		wielditem:set_name("bow:wood_bow_2")
	elseif wielditem:get_name()=="bow:wood_bow_2" and os.time()-bow_load[player:get_player_name()]>charge_speed*2 then
		wielditem:set_name("bow:wood_bow_3")
	end
	player:set_wielded_item(wielditem)
end)

extended_api.register_playerloop(function(dtime, _, player)
	local wielditem = player:get_wielded_item()
	if wielditem:get_name()=="bow:wood_bow_dropped" then
		wielditem:set_name("bow:wood_bow")
		player:set_wielded_item(wielditem)
	end
	local controls = player:get_player_control()
	timer = timer+dtime
	local inv = minetest.get_inventory({type="player", name=player:get_player_name()})
	if bow_load[player:get_player_name()] and (wielditem:get_name()~="bow:wood_bow_1" and wielditem:get_name()~="bow:wood_bow_2" and wielditem:get_name()~="bow:wood_bow_3") then
		local list = inv:get_list("main")
		for place, stack in pairs(list) do
			if stack:get_name()=="bow:wood_bow_1" or stack:get_name()=="bow:wood_bow_2" or stack:get_name()=="bow:wood_bow_3" then
				stack:set_name("bow:wood_bow")
				list[place]=stack
				break
			end
		end
		inv:set_list("main", list)
		player:set_physics_override({speed=1})
		player:set_eye_offset({x=0,y=0,z=0},{x=0,y=0,z=0})
		bow_load[player:get_player_name()]=false
	end
end)

minetest.register_craft({
	output = "bow:wood_bow",
	recipe = {
		{"", "default:stick", "farming:cotton"},
		{"default:stick", "", "farming:cotton"},
		{"", "default:stick", "farming:cotton"},
	}
})

minetest.register_craft({
	output = "bow:flint_arrow 16",
	recipe = {
		{"default:flint"},
		{"default:stick"},
		{"default:paper"},
	}
})
