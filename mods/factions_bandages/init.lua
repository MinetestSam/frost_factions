minetest.register_alias("bandage", "factions_bandages:bandage")

local healing_limit = 15

minetest.register_craftitem("factions_bandages:bandage", {
	description = "Bandage, heals teammates for 3-4 HP until HP is equal to "..healing_limit,
	inventory_image = "factions_bandage.png",
	on_use = function(itemstack, player, pointed_thing)
	if pointed_thing.type ~= "object" then
		return
	end
	local object = pointed_thing.ref
	if not object:is_player() then
		return
	end
	local pname = object:get_player_name()
	local name = player:get_player_name()
	if factions.get_player_faction(pname) == factions.get_player_faction(name) then
			local hp = object:get_hp()
			if hp > 0 and hp < healing_limit then
				hp = hp + math.random(3,4)
				if hp > healing_limit then
					hp = healing_limit
				end
				object:set_hp(hp)
				itemstack:take_item()
				return itemstack
			else
				minetest.chat_send_player(name, pname .. " has " .. hp .. " HP. You can't heal them.")
			end
	else
		minetest.chat_send_player(name, pname.." isn't in your team!")
	end
end,
})

minetest.register_craft({
	type = "shaped",
	output = "factions_bandages:bandage",
	recipe = {
		{"farming:cotton", "farming:cotton", "farming:cotton"},
		{"farming:cotton", "group:wool", "farming:cotton"},
		{"farming:cotton", "farming:cotton", "farming:cotton"}
	}
})
