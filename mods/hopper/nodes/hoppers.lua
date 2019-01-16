-- internationalization boilerplate
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- formspec
local function get_hopper_formspec(pos)
	local spos = hopper.get_string_pos(pos)
	local formspec =
		"size[8,9]"
		.. hopper.formspec_bg
		.. "list[nodemeta:" .. spos .. ";main;2,0.3;4,4;]"
		.. hopper.get_eject_button_texts(pos, 7, 2)
		.. "list[current_player;main;0,4.85;8,1;]"
		.. "list[current_player;main;0,6.08;8,3;8]"
		.. "listring[nodemeta:" .. spos .. ";main]"
		.. "listring[current_player;main]"
	return formspec
end

local hopper_on_place = function(itemstack, placer, pointed_thing, node_name)
	local pos  = pointed_thing.under
	local pos2 = pointed_thing.above
	local x = pos.x - pos2.x
	local z = pos.z - pos2.z

	local returned_stack, success
	-- unfortunately param2 overrides are needed for side hoppers even in the non-single-craftable-item case
	-- because they are literally *side* hoppers - their spouts point to the side rather than to the front, so
	-- the default item_place_node orientation code will not orient them pointing toward the selected surface.
	if x == -1 and (hopper.config.single_craftable_item or node_name == "hopper:hopper_side") then
		returned_stack, success = minetest.item_place_node(ItemStack("hopper:hopper_side"), placer, pointed_thing, 0)
	elseif x == 1 and (hopper.config.single_craftable_item or node_name == "hopper:hopper_side") then
		returned_stack, success = minetest.item_place_node(ItemStack("hopper:hopper_side"), placer, pointed_thing, 2)
	elseif z == -1 and (hopper.config.single_craftable_item or node_name == "hopper:hopper_side")  then
		returned_stack, success = minetest.item_place_node(ItemStack("hopper:hopper_side"), placer, pointed_thing, 3)
	elseif z == 1 and (hopper.config.single_craftable_item or node_name == "hopper:hopper_side") then
		returned_stack, success = minetest.item_place_node(ItemStack("hopper:hopper_side"), placer, pointed_thing, 1)
	else
		if hopper.config.single_craftable_item then
			node_name = "hopper:hopper" -- For cases where single_craftable_item was set on an existing world and there are still side hoppers in player inventories
		end
		returned_stack, success = minetest.item_place_node(ItemStack(node_name), placer, pointed_thing)
	end
	
	if success then
		local meta = minetest.get_meta(pos2)
		meta:set_string("placer", placer:get_player_name())
		if not minetest.settings:get_bool("creative_mode") then
			itemstack:take_item()
		end
	end
	return itemstack
end

-- Used to convert side hopper facing into source and destination relative coordinates
-- This was tedious to populate and test
local directions = {
	[0]={["src"]={x=0, y=1, z=0},["dst"]={x=-1, y=0, z=0}},
	[1]={["src"]={x=0, y=1, z=0},["dst"]={x=0, y=0, z=1}},
	[2]={["src"]={x=0, y=1, z=0},["dst"]={x=1, y=0, z=0}},
	[3]={["src"]={x=0, y=1, z=0},["dst"]={x=0, y=0, z=-1}},
	[4]={["src"]={x=0, y=0, z=1},["dst"]={x=-1, y=0, z=0}},
	[5]={["src"]={x=0, y=0, z=1},["dst"]={x=0, y=-1, z=0}},
	[6]={["src"]={x=0, y=0, z=1},["dst"]={x=1, y=0, z=0}},
	[7]={["src"]={x=0, y=0, z=1},["dst"]={x=0, y=1, z=0}},
	[8]={["src"]={x=0, y=0, z=-1},["dst"]={x=-1, y=0, z=0}},
	[9]={["src"]={x=0, y=0, z=-1},["dst"]={x=0, y=1, z=0}},
	[10]={["src"]={x=0, y=0, z=-1},["dst"]={x=1, y=0, z=0}},
	[11]={["src"]={x=0, y=0, z=-1},["dst"]={x=0, y=-1, z=0}},
	[12]={["src"]={x=1, y=0, z=0},["dst"]={x=0, y=1, z=0}},
	[13]={["src"]={x=1, y=0, z=0},["dst"]={x=0, y=0, z=1}},
	[14]={["src"]={x=1, y=0, z=0},["dst"]={x=0, y=-1, z=0}},
	[15]={["src"]={x=1, y=0, z=0},["dst"]={x=0, y=0, z=-1}},
	[16]={["src"]={x=-1, y=0, z=0},["dst"]={x=0, y=-1, z=0}},
	[17]={["src"]={x=-1, y=0, z=0},["dst"]={x=0, y=0, z=1}},
	[18]={["src"]={x=-1, y=0, z=0},["dst"]={x=0, y=1, z=0}},
	[19]={["src"]={x=-1, y=0, z=0},["dst"]={x=0, y=0, z=-1}},
	[20]={["src"]={x=0, y=-1, z=0},["dst"]={x=1, y=0, z=0}},
	[21]={["src"]={x=0, y=-1, z=0},["dst"]={x=0, y=0, z=1}},
	[22]={["src"]={x=0, y=-1, z=0},["dst"]={x=-1, y=0, z=0}},
	[23]={["src"]={x=0, y=-1, z=0},["dst"]={x=0, y=0, z=-1}},
}

local bottomdir = function(facedir)
	return ({[0]={x=0, y=-1, z=0},
		{x=0, y=0, z=-1},
		{x=0, y=0, z=1},
		{x=-1, y=0, z=0},
		{x=1, y=0, z=0},
		{x=0, y=1, z=0}})[math.floor(facedir/4)]
end

local function hopper_tick(pos)

	local inv = minetest.get_meta(pos):get_inventory()
	local posob

	for _,object in pairs(minetest.get_objects_inside_radius(pos, 1.85)) do
		if not object:is_player()
		and object:get_luaentity()
		and object:get_luaentity().name == "__builtin:item"
		and inv
		and inv:room_for_item("main",
			ItemStack(object:get_luaentity().itemstring)) then

			posob = object:getpos()

			if math.abs(posob.x - pos.x) <= 0.5
			and posob.y - pos.y <= 0.85
			and posob.y - pos.y >= 0.3 then

				inv:add_item("main",
					ItemStack(object:get_luaentity().itemstring))

				object:get_luaentity().itemstring = ""
				object:remove()
			end
		end
	end
	
	local node = minetest.get_node(pos)

	local source_pos, destination_pos, destination_dir
	if node.name == "hopper:hopper_side" then
		source_pos = vector.add(pos, directions[node.param2].src)
		destination_dir = directions[node.param2].dst
		destination_pos = vector.add(pos, destination_dir)
	else
		destination_dir = bottomdir(node.param2)
		source_pos = vector.subtract(pos, destination_dir)
		destination_pos = vector.add(pos, destination_dir)
	end
	
	local output_direction
	if destination_dir.y == 0 then
		output_direction = "horizontal"
	end
	
	local source_node = minetest.get_node(source_pos)
	local destination_node = minetest.get_node(destination_pos)

	local registered_source_inventories = hopper.get_registered_inventories_for(source_node.name)
	if registered_source_inventories ~= nil then
		hopper.take_item_from(pos, source_pos, source_node, registered_source_inventories["top"])
	end
	
	local registered_destination_inventories = hopper.get_registered_inventories_for(destination_node.name)
	if registered_destination_inventories ~= nil then
		if output_direction == "horizontal" then
			hopper.send_item_to(pos, destination_pos, destination_node, registered_destination_inventories["side"])
		else
			hopper.send_item_to(pos, destination_pos, destination_node, registered_destination_inventories["bottom"])
		end
	else
		hopper.send_item_to(pos, destination_pos, destination_node) -- for handling ejection
	end
	
	if inv and not inv:is_empty("main") then
		return true
	end
end

-------------------------------------------------------------------------------------------
-- Hoppers

minetest.register_node("hopper:hopper", {
	drop = "hopper:hopper",
	description = S("Hopper"),
	_doc_items_longdesc = hopper.doc.hopper_long_desc,
    _doc_items_usagehelp = hopper.doc.hopper_usage,
	groups = {cracky = 3},
	sounds = hopper.metal_sounds,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {
		"hopper_top_" .. hopper.config.texture_resolution .. ".png",
		"hopper_top_" .. hopper.config.texture_resolution .. ".png",
		"hopper_front_" .. hopper.config.texture_resolution .. ".png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
			{0.4, 0.0, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.0, -0.5, -0.4, 0.5, 0.5},
			{-0.5, 0.0, -0.5, 0.5, 0.5, -0.4},
			--funnel base
			{-0.5, 0.0, -0.5, 0.5, 0.1, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.15, -0.3, -0.15, 0.15, -0.7, 0.15},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--funnel
			{-0.5, 0.0, -0.5, 0.5, 0.5, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.15, -0.3, -0.15, 0.15, -0.7, 0.15},
		},
	},

	on_construct = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		inv:set_size("main", 4*4)
		minetest.get_node_timer(pos):start(1.0)
	end,

	on_place = function(itemstack, placer, pointed_thing)
		return hopper_on_place(itemstack, placer, pointed_thing, "hopper:hopper")
	end,

	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("main")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)
		if minetest.is_protected(pos, clicker:get_player_name()) and not minetest.check_player_privs(clicker, "protection_bypass") then
			return
		end
		minetest.show_formspec(clicker:get_player_name(),
			"hopper_formspec:"..minetest.pos_to_string(pos), get_hopper_formspec(pos))
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", S("@1 moves stuff in hopper at @2",
			player:get_player_name(), minetest.pos_to_string(pos)))
		local timer1 = minetest.get_node_timer(pos)
		if not timer1:is_started() then
			timer1:start(1.0)
		end
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", S("@1 moves stuff to hopper at @2",
			player:get_player_name(), minetest.pos_to_string(pos)))
		local timer1 = minetest.get_node_timer(pos)
		if not timer1:is_started() then
			timer1:start(1.0)
		end
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", S("@1 moves stuff from hopper at @2",
			player:get_player_name(), minetest.pos_to_string(pos)))
		local timer1 = minetest.get_node_timer(pos)
		if not timer1:is_started() then
			timer1:start(1.0)
		end
	end,
	
	on_timer = hopper_tick,
})

local hopper_side_drop
local hopper_groups
if hopper.config.single_craftable_item then
	hopper_side_drop = "hopper:hopper"
	hopper_groups = {cracky=3, not_in_creative_inventory = 1}
else
	hopper_side_drop = "hopper:hopper_side"
	hopper_groups = {cracky=3}
end

minetest.register_node("hopper:hopper_side", {
	description = S("Side Hopper"),
	_doc_items_longdesc = hopper.doc.hopper_long_desc,
    _doc_items_usagehelp = hopper.doc.hopper_usage,
	drop = hopper_side_drop,
	groups = hopper_groups,
	sounds = hopper.metal_sounds,
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {
		"hopper_top_" .. hopper.config.texture_resolution .. ".png",
		"hopper_bottom_" .. hopper.config.texture_resolution .. ".png",
		"hopper_back_" .. hopper.config.texture_resolution .. ".png",
		"hopper_side_" .. hopper.config.texture_resolution .. ".png",
		"hopper_back_" .. hopper.config.texture_resolution .. ".png",
		"hopper_back_" .. hopper.config.texture_resolution .. ".png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			--funnel walls
			{-0.5, 0.0, 0.4, 0.5, 0.5, 0.5},
			{0.4, 0.0, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.0, -0.5, -0.4, 0.5, 0.5},
			{-0.5, 0.0, -0.5, 0.5, 0.5, -0.4},
			--funnel base
			{-0.5, 0.0, -0.5, 0.5, 0.1, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.7, -0.3, -0.15, 0.15, 0.0, 0.15},
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			--funnel
			{-0.5, 0.0, -0.5, 0.5, 0.5, 0.5},
			--spout
			{-0.3, -0.3, -0.3, 0.3, 0.0, 0.3},
			{-0.7, -0.3, -0.15, 0.15, 0.0, 0.15},
		},
	},
	
	on_construct = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		inv:set_size("main", 4*4)
		minetest.get_node_timer(pos):start(1.0)
	end,

	on_place = function(itemstack, placer, pointed_thing)
		return hopper_on_place(itemstack, placer, pointed_thing, "hopper:hopper_side")
	end,
	
	can_dig = function(pos,player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("main")
	end,

	on_rightclick = function(pos, node, clicker, itemstack)
		if minetest.is_protected(pos, clicker:get_player_name()) and not minetest.check_player_privs(clicker, "protection_bypass") then
			return
		end
		minetest.show_formspec(clicker:get_player_name(),
			"hopper_formspec:"..minetest.pos_to_string(pos), get_hopper_formspec(pos))
	end,

	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", S("@1 moves stuff in hopper at @2",
			player:get_player_name(), minetest.pos_to_string(pos)))
		local timer1 = minetest.get_node_timer(pos)
		if not timer1:is_started() then
			timer1:start(1.0)
		end
	end,

	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", S("@1 moves stuff to hopper at @2",
			player:get_player_name(), minetest.pos_to_string(pos)))
		local timer1 = minetest.get_node_timer(pos)
		if not timer1:is_started() then
			timer1:start(1.0)
		end
	end,

	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", S("@1 moves stuff from hopper at @2",
			player:get_player_name(), minetest.pos_to_string(pos)))
		local timer1 = minetest.get_node_timer(pos)
		if not timer1:is_started() then
			timer1:start(1.0)
		end
	end,
	
	on_timer = hopper_tick,
})
