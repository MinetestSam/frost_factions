

-- CookieDonut
minetest.register_craftitem("moardonutz:cookiedonut", {
	description = ("CookieDonut"),
	inventory_image = "moardonutz_cookiedonut.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craft({
	output = "moardonutz:cookiedonut",
	type = "shapeless",
	recipe = {"farming:cookie", "farming:donut"},
})	

--sprinkles

minetest.register_craftitem("moardonutz:sprinkles",{
	description = "Sprinkles",
	inventory_image = "moardonutz_sprinkles.png",
})	

minetest.register_craft({
	output = "moardonutz:sprinkles",
	type = "shapeless",
	recipe = {"farming:sugar","group:dye"},
})	

--Sprinkle Donut

minetest.register_craftitem("moardonutz:sprinkledonut", {
	description = ("SprinkleDonut"),
	inventory_image = "moardonutz_sprinkledonut.png",
	on_use = minetest.item_eat(4),
})

minetest.register_craft({
	output = "moardonutz:sprinkledonut",
	type = "shapeless",
	recipe = {"farming:donut","moardonutz:sprinkles"},
})	

-- pancake

minetest.register_craftitem("moardonutz:pancake", {
	description = ("Pancake"),
	inventory_image = "moardonutz_pancake.png",
	on_use = minetest.item_eat(3),
})

minetest.register_craft({
    type = "shaped",
    output = "moardonutz:pancake 2",
    recipe = {
        {"farming:wheat", "farming:wheat","farming:wheat"},
        {"farming:sugar", "farming:sugar",  "farming:sugar"},
        {"farming:wheat", "farming:wheat",  "farming:wheat"}
    }
})

--waffle

minetest.register_craftitem("moardonutz:waffle", {
	description = ("Waffle"),
	inventory_image = "moardonutz_waffle.png",
	on_use = minetest.item_eat(3),
})

minetest.register_craft({
    type = "shaped",
    output = "moardonutz:waffle 2",
    recipe = {
        {"farming:wheat", "farming:sugar","farming:wheat"},
        {"farming:sugar", "farming:wheat",  "farming:sugar"},
        {"farming:wheat", "farming:sugar",  "farming:wheat"}
    }
})
