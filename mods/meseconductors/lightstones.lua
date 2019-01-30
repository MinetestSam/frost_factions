



local rules_all_directions =
{{x=0,  y=0,  z=-1},
 {x=1,  y=0,  z=0},
 {x=-1, y=0,  z=0},
 {x=0,  y=0,  z=1},
 {x=1,  y=1,  z=0},
 {x=1,  y=-1, z=0},
 {x=-1, y=1,  z=0},
 {x=-1, y=-1, z=0},
 {x=0,  y=1,  z=1},
 {x=0,  y=-1, z=1},
 {x=0,  y=1,  z=-1},
 {x=0,  y=1,  z=0},
 {x=0,  y=-1,  z=0},
 {x=0,  y=-1, z=-1}}


function meseconductors:lightstone_add(name, color, base_item)
	minetest.register_node("meseconductors:lightstone_" .. color .. "_off", {
		tiles = {"meseconductors_lightstone_" .. color .. "_off.png"},
		groups = {cracky=2, mesecon_effector_off = 1, mesecon = 2},
		description=name.." Lightstone",
		sounds = default.node_sound_glass_defaults(),
		mesecons = {effector = {
			rules = rules_all_directions,
			action_on = function (pos, node)
				minetest.swap_node(pos, {name = "meseconductors:lightstone_" .. color .. "_on", param2 = node.param2})
			end,
		}}
	})
	minetest.register_node("meseconductors:lightstone_" .. color .. "_on", {
	tiles = {"meseconductors_lightstone_" .. color .. "_on.png"},
	groups = {cracky=2,not_in_creative_inventory=1, mesecon = 2},
	drop = "meseconductors:lightstone_" .. color .. "_off",
	light_source = 13,
	sounds = default.node_sound_glass_defaults(),
	mesecons = {effector = {
		rules = rules_all_directions,
		action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:lightstone_" .. color .. "_off", param2 = node.param2})
		end,
	}}
	})

	minetest.register_craft({
		output = "meseconductors:lightstone_" .. color .. "_off 2",
		recipe = {
			{"default:glass",base_item,"default:glass"},
			{base_item,"default:torch",base_item},
			{"default:glass","meseconductors:lamp_controller","default:glass"}
		}
	})
end


meseconductors:lightstone_add("Red", "red", "dye:red")
meseconductors:lightstone_add("Green", "green", "dye:green")
meseconductors:lightstone_add("Blue", "blue", "dye:blue")
meseconductors:lightstone_add("Yellow", "yellow", "dye:yellow")
meseconductors:lightstone_add("White", "white", "dye:white")
meseconductors:lightstone_add("Pink", "pink", "dye:pink")
meseconductors:lightstone_add("Cyan", "cyan", "dye:cyan")
meseconductors:lightstone_add("Orange", "orange", "dye:orange")
meseconductors:lightstone_add("Black", "black", "dye:black")













