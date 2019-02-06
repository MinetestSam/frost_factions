ts_doors = {}

ts_doors.registered_doors = {}

ts_doors.sounds = {}

if default.node_sound_metal_defaults then
	ts_doors.sounds.metal = {
		sounds = default.node_sound_metal_defaults(),
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
	}
else
	ts_doors.sounds.metal = {
		sounds = default.node_sound_stone_defaults(),
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
	}
end

ts_doors.sounds.wood = {
	sounds = default.node_sound_wood_defaults(),
	sound_open = "doors_door_open",
	sound_close = "doors_door_close"
}

ts_doors.sounds.glass = {
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
}

local function get_door_name(meta, item)
	local door = ""
	local trapdoor = meta:get_int("trapdoor") == 1
	local locked = meta:get_int("locked") == 1
	local solid = meta:get_int("solid") == 1
	if trapdoor then
		if locked then
			if solid then
				door = "ts_doors:trapdoor_full_locked_" .. item:gsub(":", "_")
			else
				door = "ts_doors:trapdoor_locked_" .. item:gsub(":", "_")
			end
		else
			if solid then
				door = "ts_doors:trapdoor_full_" .. item:gsub(":", "_")
			else
				door = "ts_doors:trapdoor_" .. item:gsub(":", "_")
			end
		end
	else
		if locked then
			if solid then
				door = "ts_doors:door_full_locked_" .. item:gsub(":", "_")
			else
				door = "ts_doors:door_locked_" .. item:gsub(":", "_")
			end
		else
			if solid then
				door = "ts_doors:door_full_" .. item:gsub(":", "_")
			else
				door = "ts_doors:door_" .. item:gsub(":", "_")
			end
		end
	end
	return door
end

local function register_alias(name, convert_to)
	minetest.register_alias(name, convert_to)
	minetest.register_alias(name .. "_a", convert_to .. "_a")
	minetest.register_alias(name .. "_b", convert_to .. "_b")
end

function ts_doors.register_door(item, description, texture, sounds, recipe)
	recipe = recipe or item
	if not minetest.registered_nodes[item] then
		minetest.log("[ts_doors] bug found: "..item.." is not a registered node. Cannot create doors")
		return
	end
	if not sounds then
		sounds = {}
	end

	register_alias("doors:ts_door_" .. item:gsub(":", "_"), "ts_doors:door_" .. item:gsub(":", "_"))
	register_alias("doors:ts_door_full_" .. item:gsub(":", "_"), "ts_doors:door_full_" .. item:gsub(":", "_"))
	register_alias("doors:ts_door_locked_" .. item:gsub(":", "_"), "ts_doors:door_locked_" .. item:gsub(":", "_"))
	register_alias("doors:ts_door_full_locked_" .. item:gsub(":", "_"), "ts_doors:door_full_locked_" .. item:gsub(":", "_"))

	local groups = minetest.registered_nodes[item].groups
	local door_groups = {door = 1}
	for k, v in pairs(groups) do
		if k ~= "wood" then
			door_groups[k] = v
		end
	end

	local trapdoor_groups = table.copy(door_groups)

	doors.register("ts_doors:door_" .. item:gsub(":", "_"), {
		tiles = { { name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base.png^[noalpha^[makealpha:0,255,0", backface_culling = true } },
		description = description .. " Windowed Door",
		inventory_image = "[combine:32x32:0,8=" .. texture .. ":16,8=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_inv.png^[noalpha^[makealpha:0,255,0",
		groups = door_groups,
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
		recipe = {
			{recipe, recipe},
			{recipe, recipe},
			{recipe, recipe},
		}
	})
	
	doors.register("ts_doors:door_full_" .. item:gsub(":", "_"), {
		tiles = { { name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_full.png^[noalpha", backface_culling = true } },
		description = "Solid " .. description .. " Door",
		inventory_image = "[combine:32x32:0,8=" .. texture .. ":16,8=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_full_inv.png^[noalpha^[makealpha:0,255,0",
		groups = door_groups,
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
		recipe = {
			{recipe},
			{"ts_doors:door_" .. item:gsub(":", "_")},
		}
	})
	
	doors.register_trapdoor("ts_doors:trapdoor_" .. item:gsub(":", "_"), {
		description = "Windowed " .. description .. " Trapdoor",
		inventory_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor.png^[noalpha^[makealpha:0,255,0",
		wield_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor.png^[noalpha^[makealpha:0,255,0",
		tile_front = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor.png^[noalpha^[makealpha:0,255,0",
		tile_side = texture .. "^[colorize:#fff:30",
		groups = trapdoor_groups,
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})
	
	doors.register_trapdoor("ts_doors:trapdoor_full_" .. item:gsub(":", "_"), {
		description = "Solid " .. description .. " Trapdoor",
		inventory_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full.png^[noalpha",
		wield_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full.png^[noalpha",
		tile_front = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full.png^[noalpha",
		tile_side = texture .. "^[colorize:#fff:30",
		groups = trapdoor_groups,
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})
	
	minetest.register_craft({
		output = "ts_doors:trapdoor_" .. item:gsub(":", "_"),
		recipe = {
			{recipe, recipe},
			{recipe, recipe},
		}
	})

	minetest.register_craft({
		output = "ts_doors:trapdoor_full_" .. item:gsub(":", "_"),
		recipe = {
			{recipe},
			{"ts_doors:trapdoor_" .. item:gsub(":", "_")},
		}
	})
end

ts_doors.register_door("default:aspen_wood", "Aspen", "default_aspen_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:pine_wood", "Pine", "default_pine_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:acacia_wood", "Acacia", "default_acacia_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:wood", "Wooden", "default_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:junglewood", "Jungle Wood", "default_junglewood.png", ts_doors.sounds.wood)

--[[
if minetest.get_modpath("moretrees") then
	ts_doors.register_door("moretrees:apple_tree_planks", "Apple Tree", "moretrees_apple_tree_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:beech_planks", "Beech", "moretrees_beech_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:birch_planks", "Birch", "moretrees_birch_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:fir_planks", "Fir", "moretrees_fir_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:oak_planks", "Oak", "moretrees_oak_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:palm_planks", "Palm", "moretrees_palm_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:rubber_tree_planks", "Rubber Tree", "moretrees_rubber_tree_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:sequoia_planks", "Sequoia", "moretrees_sequoia_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:spruce_planks", "Spruce", "moretrees_spruce_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:willow_planks", "Willow", "moretrees_willow_wood.png", ts_doors.sounds.wood)
end
--]]

ts_doors.register_door("default:bronzeblock", "Bronze", "default_bronze_block.png", ts_doors.sounds.metal)
ts_doors.register_door("default:copperblock", "Copper", "default_copper_block.png", ts_doors.sounds.metal)
ts_doors.register_door("default:diamondblock", "Diamond", "default_diamond_block.png", ts_doors.sounds.metal)
ts_doors.register_door("default:goldblock", "Gold", "default_gold_block.png", ts_doors.sounds.metal)
ts_doors.register_door("default:steelblock", "Steel", minetest.registered_nodes["default:steelblock"].tiles[1], ts_doors.sounds.metal)

--[[
if minetest.get_modpath("moreores") then
	ts_doors.register_door("moreores:mithril_block", "Mithril", "moreores_mithril_block.png", ts_doors.sounds.metal, "moreores:mithril_ingot")
	ts_doors.register_door("moreores:silver_block", "Silver", "moreores_silver_block.png", ts_doors.sounds.metal, "moreores:silver_ingot")
	ts_doors.register_door("moreores:tin_block", "Tin", "moreores_tin_block.png", ts_doors.sounds.metal, "moreores:tin_ingot")
end

if minetest.get_modpath("technic") then
	ts_doors.register_door("technic:brass_block", "Brass", "technic_brass_block.png", ts_doors.sounds.metal, "technic:brass_ingot")
	ts_doors.register_door("technic:carbon_steel_block", "Carbon Steel", "technic_carbon_steel_block.png", ts_doors.sounds.metal, "technic:carbon_steel_ingot")
	ts_doors.register_door("technic:cast_iron_block", "Cast Iron", "technic_cast_iron_block.png", ts_doors.sounds.metal, "technic:cast_iron_ingot")
	ts_doors.register_door("technic:chromium_block", "Chromium", "technic_chromium_block.png", ts_doors.sounds.metal, "technic:chromium_ingot")
	ts_doors.register_door("technic:lead_block", "Lead", "technic_lead_block.png", ts_doors.sounds.metal, "technic:lead_ingot")
	ts_doors.register_door("technic:stainless_steel_block", "Stainless Steel", "technic_stainless_steel_block.png", ts_doors.sounds.metal, "technic:stainless_steel_ingot")
	ts_doors.register_door("technic:zinc_block", "Zinc", "technic_zinc_block.png", ts_doors.sounds.metal, "technic:zinc_ingot")

	ts_doors.register_door("technic:concrete", "Concrete", "technic_concrete_block.png", ts_doors.sounds.metal)
	ts_doors.register_door("technic:blast_resistant_concrete", "Blast Resistant Concrete", "technic_blast_resistant_concrete_block.png", ts_doors.sounds.metal)
end
--]]

minetest.override_item("doors:door_steel", {
	description = "Windowed Plain Steel Door",
})

minetest.override_item("doors:door_wood", {
	description = "Windowed Mixed Wood Door",
})

minetest.override_item("doors:trapdoor", {
	description = "Windowed Mixed Wood Trapdoor",
})

minetest.override_item("doors:trapdoor_steel", {
	description = "Windowed Plain Steel Trapdoor",
})

minetest.register_craft({
	type = "shapeless",
	output = "doors:door_wood",
	recipe = {"ts_doors:door_default_aspen_wood"},
})

minetest.register_craft({
	type = "shapeless",
	output = "doors:door_wood",
	recipe = {"ts_doors:door_default_pine_wood"},
})

minetest.register_craft({
	type = "shapeless",
	output = "doors:door_wood",
	recipe = {"ts_doors:door_default_acacia_wood"},
})

minetest.register_craft({
	type = "shapeless",
	output = "doors:door_wood",
	recipe = {"ts_doors:door_default_wood"},
})

minetest.register_craft({
	type = "shapeless",
	output = "doors:door_wood",
	recipe = {"ts_doors:door_default_junglewood"},
})
