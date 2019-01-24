--------------
-- TODO: Check for terrain height

-- Defines the edge of a world
local edge = 3000
-- Radius which should be checked for a good teleportation place
local radius = 2
--------------

local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "World edge: " .. edge)
end

local waiting_list = {}
--[[ Explanation of waiting_list table
	Index = Player name
	Value = {
		player = Player to teleport
		pos = Destination
		obj = Attacked entity
		notified = When the player must wait longer...
	}
]]

local function findsurface(player, pos)
	if not player or not player:is_player() then
		return
	end
	local pos2 = {
		x = pos.x,
		y = pos.y + 510,
		z = pos.z
	}
	
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos, pos2)
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()
	
	local x = pos.x
	local y1 = pos.y
	local y2 = pos2.y
	local z = pos.z
	
	local tp_pos = nil
	
	for y = y1, y2 do
		if y + 2 > y2 then
			break
		end
		local node = data[area:index(x, y, z)]
		if node ~= c_air then
			local chk2 = data[area:index(x, y + 1, z)]
			local chk3 = data[area:index(x, y + 2, z)]
			if chk2 == c_air and chk3 == c_air then
				tp_pos = vector.new(x, y + 1, z)
			end
		end
	end
	
	if tp_pos then
		local v = waiting_list[player:get_player_name()]
		local pl = v.player
		local name = pl:get_player_name()
		v.obj:setpos(tp_pos)
		minetest.after(0.2, function(p, o)
			p:set_detach()
			o:remove()
		end, pl, v.obj)
		minetest.chat_send_player(name, "A free place was found.")
		waiting_list[name] = nil
		return
	else
		minetest.after(0.5, findsurface, player, pos2)
	end
end

local function step()
	for k, v in pairs(waiting_list) do
		if v.player and v.player:is_player() then
			local pos = get_surface_pos(v.pos)
			if pos then
				v.obj:setpos(pos)
				minetest.after(0.2, function(p, o)
					p:set_detach()
					o:remove()
				end, v.player, v.obj)
				waiting_list[k] = nil
			elseif not v.notified then
				v.notified = true
				minetest.chat_send_player(k, "Sorry, we have not found a free place yet. Please be patient.")
				minetest.after(1, findsurface, v.player, v.pos)
			end
		else
			v.obj:remove()
			waiting_list[k] = nil
		end
	end

	local newedge = edge - 5
	-- Check if the players are near the edge and teleport them
	local players = minetest.get_connected_players()
	for i, player in ipairs(players) do
		local name = player:get_player_name()
		if not waiting_list[name] then
			local pos = vector.round(player:getpos())
			local newpos = nil
			if pos.x >= edge then
				newpos = {x = -newedge, y = 10, z = pos.z}
			elseif pos.x <= -edge then
				newpos = {x = newedge, y = 10, z = pos.z}
			end
			 
			if pos.z >= edge then
				newpos = {x = pos.x, y = 10, z = -newedge}
			elseif pos.z <= -edge then
				newpos = {x = pos.x, y = 10, z = newedge}
			end
			
			-- Teleport the player
			if newpos then
				minetest.chat_send_player(name, "Please wait a few seconds. We will teleport you soon.")
				local obj = minetest.add_entity(newpos, "worldedge:lock")
				player:set_attach(obj, "", {x=0, y=0, z=0}, {x=0, y=0, z=0})
				waiting_list[name] = {
					player = player,
					pos = newpos,
					obj = obj
				}
				obj:setpos(newpos)
			end
		end
	end
	minetest.after(3, step)
end

step()

function get_surface_pos(pos)
	local minp = {
		x = pos.x - radius - 1,
		y = -10,
		z = pos.z - radius - 1
	}
	local maxp = {
		x = pos.x + radius - 1,
		y = 50,
		z = pos.z + radius - 1
	}
	
	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(minp, maxp)
	local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()
	
	local seen_air = false
	local deepest_place = vector.new(pos)
	deepest_place.y = 50
	
	for x = minp.x, maxp.x do
	for z = minp.z, maxp.z do
		local solid = 0
		for y = deepest_place.y, -10, -1 do
			local node = data[area:index(x, y, z)]
			if y < deepest_place.y and node == c_air then
				deepest_place = vector.new(x, y, z)
				seen_air = true
			end
			if solid > 5 then
				-- Do not find caves!
				break
			end
			if node ~= c_air and node ~= c_ignore then
				solid = solid + 1
			end
		end
	end
	end
	
	local node1 = data[area:index(deepest_place.x, deepest_place.y, deepest_place.z)]
	local node2 = data[area:index(deepest_place.x, deepest_place.y + 1, deepest_place.z)]
	
	if node1 ~= c_air and node2 ~= c_air then
		return false
	end
	
	if seen_air then
		return deepest_place
	else
		return false
	end
end

minetest.register_entity("worldedge:lock", {
	initial_properties = {
		is_visible = false
	},
	on_activate = function(staticdata, dtime_s)
		--self.object:set_armor_groups({immortal = 1})
	end
})
