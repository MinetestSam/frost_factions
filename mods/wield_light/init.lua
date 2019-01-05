local sources = {}

-- api --

wield_light = {
	register_source = function(name) sources[name] = true end,
	unregister_source = function(name) sources[name] = nil end,
}

-- registration --

local positions = {}
local HELPER_NAME = 'wield_light:helper'

minetest.register_node(HELPER_NAME, {
	walkable = false,
	pointable = false,
	diggable = false,
	climbable = false,
	sunlight_propagates = true,
	drawtype = 'airlike',
	light_source = 14,
	on_timer = function(pos)
		if positions[minetest.hash_node_position(pos)] == true then
			positions[minetest.hash_node_position(pos)] = false
			return true
		else
			positions[minetest.hash_node_position(pos)] = nil
			minetest.remove_node(pos)
		end
	end,
})

local c_air = minetest.get_content_id("air")
local c_helper_name = minetest.get_content_id(HELPER_NAME)
local function step()
	for _, player in pairs(minetest.get_connected_players()) do
		local item = player:get_wielded_item():get_name()
		if not sources[item] then
			return
		end
		local pos = vector.round(player:getpos())
		pos.y = pos.y + 1
		if positions[minetest.hash_node_position(pos)] == nil then
			
			local vm = minetest.get_voxel_manip()
			
			local emin, emax = vm:read_from_map(pos, pos)
			
			local a = VoxelArea:new{
				MinEdge = emin,
				MaxEdge = emax
			}
			
			local data = vm:get_data()
			
			local target_node = a:index(pos.x, pos.y, pos.z)
			
			local target_node_data = data[target_node]
			
			if target_node_data == c_air and target_node_data ~= c_helper_name then
				data[target_node] = c_helper_name
				vm:set_data(data)
				vm:write_to_map(true)
				minetest.get_node_timer(pos):start(0.3)
			end
			positions[minetest.hash_node_position(pos)] = true
		elseif positions[minetest.hash_node_position(pos)] == false then
			positions[minetest.hash_node_position(pos)] = true
		end
	end
	minetest.after(0.2, step)
end

step()

wield_light.register_source('default:torch')
wield_light.register_source('bucket:bucket_lava')
wield_light.register_source('xdecor:candle')
wield_light.register_source('xdecor:lantern')