--lockpicks v0.8 by HeroOfTheWinds
--Adds a variety of lockpicks and redefines most locked objects to allow them to be 'picked' and unlocked.

local breakexp = .66 --exponent for tools to determine 

--lockpick definitions
minetest.register_tool("lockpicks:lockpick_wood", {
	description="Wooden Lockpick",
	inventory_image = "wooden_lockpick.png",
	tool_capabilities = {
		max_drop_level = 1,
		groupcaps = {locked={maxlevel=1, uses=10, times={[3]=5.00}}}
	}
})
minetest.register_tool("lockpicks:lockpick_tin", {
	description="Tin Lockpick",
	inventory_image = "tin_lockpick.png",
	tool_capabilities = {
		max_drop_level = 2,
		groupcaps = {locked={maxlevel=2, uses=20, times={[2]=7.00,[3]=4.50}}}
	}
})
minetest.register_tool("lockpicks:lockpick_steel", {
	description="Steel Lockpick",
	inventory_image = "steel_lockpick.png",
	tool_capabilities = {
		max_drop_level = 3,
		groupcaps = {locked={maxlevel=2, uses=30, times={[2]=6.00,[3]=4.00}}}
	}
})
minetest.register_tool("lockpicks:lockpick_copper", {
	description="Copper Lockpick",
	inventory_image = "copper_lockpick.png",
	tool_capabilities = {
		max_drop_level = 4,
		groupcaps = {locked={maxlevel=3, uses=40, times={[1]=20.00,[2]=5.00,[3]=3.00}}}
	}
})
minetest.register_tool("lockpicks:lockpick_bronze", {
	description="Bronze Lockpick",
	inventory_image = "bronze_lockpick.png",
	tool_capabilities = {
		max_drop_level = 5,
		groupcaps = {locked={maxlevel=3, uses=50, times={[1]=15.00,[2]=4.50,[3]=2.00}}}
	}
})
minetest.register_tool("lockpicks:lockpick_gold", {
	description="Gold Lockpick",
	inventory_image = "gold_lockpick.png",
	tool_capabilities = {
		max_drop_level = 6,
		groupcaps = {locked={maxlevel=3, uses=50, times={[1]=10.00,[2]=4.00,[3]=1.00}}}
	}
})
minetest.register_tool("lockpicks:lockpick_diamond", {
	description="Diamond Lockpick",
	inventory_image = "diamond_lockpick.png",
	tool_capabilities = {
		max_drop_level = 7,
		groupcaps = {locked={maxlevel=3, uses=50, times={[1]=5.00,[2]=3.50,[3]=0.50}}}
	}
})

--self-explanatory - taken from original locked chest code
local function has_locked_chest_privilege(meta, player)
	if player:get_player_name() ~= meta:get_string("owner") then
		return false
	end
	return true
end


--locked node definitions

--load technic chests
modpath = minetest.get_modpath("lockpicks")

--redefine original locked chest
dofile(modpath.."/default_chest.lua")

--pick recipe definitions
minetest.register_craft({
	output = "lockpicks:lockpick_wood",
	recipe = {
		{"", "default:stick", "default:stick"},
		{"", "default:stick", ""},
		{"", "group:wood", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_tin",
	recipe = {
		{"", "default:tin_ingot", "default:tin_ingot"},
		{"", "default:tin_ingot", ""},
		{"", "group:wood", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_steel",
	recipe = {
		{"", "default:steel_ingot", "default:steel_ingot"},
		{"", "default:steel_ingot", ""},
		{"", "group:wood", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_copper",
	recipe = {
		{"", "default:copper_ingot", "default:copper_ingot"},
		{"", "default:copper_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_bronze",
	recipe = {
		{"", "default:bronze_ingot", "default:bronze_ingot"},
		{"", "default:bronze_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_gold",
	recipe = {
		{"", "default:gold_ingot", "default:gold_ingot"},
		{"", "default:gold_ingot", ""},
		{"", "default:steel_ingot", ""}
	}
})
minetest.register_craft({
	output = "lockpicks:lockpick_diamond",
	recipe = {
		{"", "default:diamond", "default:diamond"},
		{"", "default:diamond", ""},
		{"", "default:steel_ingot", ""}
	}
})