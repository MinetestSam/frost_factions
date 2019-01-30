minetest.register_craftitem("meseconductors:lamp_controller", {
	description = "Lamp Controller",
	inventory_image = "meseconductors_lamp_controller.png",
})
if minetest.get_modpath("technic") then
minetest.register_craft({
		output = "meseconductors:lamp_controller",
		recipe = {
			{ "mesecons_torch:mesecon_torch_on",     "technic:control_logic_unit",    "mesecons_torch:mesecon_torch_on"},
			{ "",     "mesecons:mesecon",    ""}
		},
})

else
minetest.register_craft({
		output = "meseconductors:lamp_controller",
		recipe = {
			{ "mesecons_torch:mesecon_torch_on",     "mesecons_luacontroller:luacontroller0000",    "mesecons_torch:mesecon_torch_on"},
			{ "",     "mesecons:mesecon",    ""}
		},
})

end



lamp_box = {
	type = "wallmounted",
	wall_top = {-0.3275,0.375,-0.3275,0.3275,0.5,0.3275},
	wall_bottom = {-0.3275,-0.5,-0.3275,0.3275,-0.375,0.3275},
	wall_side = {-0.375,-0.3275,-0.3275,-0.5,0.3275,0.3275},
}

rules_all =
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

	-- Node Definition
--to do: rename .obj and texture
minetest.register_node("meseconductors:mese_light_off", {

	    drawtype = "mesh",
	    mesh = "meseconductors_wall_lamp.obj",
	    tiles = {"meseconductors_wall_lamp.png"},
	    groups = {cracky=3},
	    paramtype = "light",
	    paramtype2 = "wallmounted",
	    description = "Wall / Ceiling Lamp",
	    selection_box = lamp_box,
	    walkable = false,

	    mesecons = {effector = {
            rules = rules_all,
	    	action_on = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:mese_light_on", param2 = node.param2})

		--on_place = minetest.rotate_node
		end,

		}}

})

--to do: rename .obj and texture
minetest.register_node("meseconductors:mese_light_on", {

	    drawtype = "mesh",
	    mesh = "meseconductors_wall_lamp.obj",
	    tiles = {"meseconductors_wall_lamp_on.png"},
	    groups = {cracky=3, not_in_creative_inventory=1},
	    paramtype = "light",
	    paramtype2 = "wallmounted",
	    description = "Wall / Ceiling Lamp (On !!)",
	    selection_box = lamp_box,
	    walkable = false,
	    --on_place = minetest.rotate_node,
	    light_source = 15,
	    drop = "meseconductors:mese_light_off",
	    mesecons = {effector = {
            rules = rules_all,
	    	action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:mese_light_off", param2 = node.param2})
			end,
		}}
})

rules_lamp_standing =
{{x=0,  y=-1,  z=0},
 {x=1,  y=0,  z=0},
 {x=-1,  y=0,  z=0},
 {x=0,  y=0,  z=-1},
 {x=0,  y=0,  z=1}}

 rules_lamp_side =
{{x=1,  y=0,  z=0},
 {x=-1,  y=0,  z=0},
 {x=0,  y=0,  z=-1},
 {x=0,  y=0,  z=1}}

minetest.register_node("meseconductors:sphere_lamp_standing_off", {

	    drawtype = "mesh",
	    mesh = "meseconductors_sphere_lamp_standing.obj",
	    tiles = {"meseconductors_sphere_lamp_standing.png"},
	    groups = {cracky=3},
	    paramtype = "light",
	    description = "Sphere Lamp",
	    use_texture_alpha = true,
	    selection_box = {
            type = "fixed",
            fixed = {-0.1200,-0.5,-0.1200,0.1200,0.185,0.1200},
	    },

	    walkable = false,
	    mesecons = {effector = {
            rules = rules_lamp_standing,
	    	action_on = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:sphere_lamp_standing_on", param2 = node.param2})

		--on_place = minetest.rotate_node
		end,

		}}

})

minetest.register_node("meseconductors:sphere_lamp_standing_on", {

	    drawtype = "mesh",
	    mesh = "meseconductors_sphere_lamp_standing.obj",
	    tiles = {"meseconductors_sphere_lamp_standing.png"},
	    groups = {cracky=3, not_in_creative_inventory=1},
	    paramtype = "light",
	    description = "Sphere Lamp (On)",
	    use_texture_alpha = true,
	    selection_box = {
            type = "fixed",
            fixed = {-0.1200,-0.5,-0.1200,0.1200,0.185,0.1200},
	    },
	    walkable = false,
	    light_source = 12,
	    on_place = minetest.rotate_node,
        drop = "meseconductors:sphere_lamp_standing_off",
	    mesecons = {effector = {
            rules = rules_lamp_standing,
	    	action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:sphere_lamp_standing_off", param2 = node.param2})

		--on_place = minetest.rotate_node
		end,

		}}

})

minetest.register_node("meseconductors:sphere_lamp_standing_tall_off", {

	    drawtype = "mesh",
	    mesh = "meseconductors_sphere_lamp_standing2.obj",
	    tiles = {"meseconductors_sphere_lamp_standing.png"},
	    groups = {cracky=3},
	    paramtype = "light",
	    description = "Sphere Lamp",
	    use_texture_alpha = true,
	    selection_box = {
            type = "fixed",
            fixed = {-0.1200,-0.5,-0.1200,0.1200,0.660,0.1200},
	    },
	    walkable = false,
	    mesecons = {effector = {
            rules = rules_lamp_standing,
	    	action_on = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:sphere_lamp_standing_tall_on", param2 = node.param2})

		--on_place = minetest.rotate_node
		end,

		}}

})

minetest.register_node("meseconductors:sphere_lamp_standing_tall_on", {

	    drawtype = "mesh",
	    mesh = "meseconductors_sphere_lamp_standing2.obj",
	    tiles = {"meseconductors_sphere_lamp_standing.png"},
	    groups = {cracky=3, not_in_creative_inventory=1},
	    paramtype = "light",
	    description = "Sphere Lamp (On)",
	    use_texture_alpha = true,
        selection_box = {
            type = "fixed",
            fixed = {-0.1200,-0.5,-0.1200,0.1200,0.660,0.1200},
	    },
	    walkable = false,
	    light_source = 12,
	    on_place = minetest.rotate_node,
        drop = "meseconductors:sphere_lamp_standing_tall_off",
	    mesecons = {effector = {
            rules = rules_lamp_standing,
	    	action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:sphere_lamp_standing_tall_off", param2 = node.param2})

		--on_place = minetest.rotate_node
		end,

		}}

})

minetest.register_node("meseconductors:sphere_lamp_wall_off", {

        description = "Sphere Lamp",
	    drawtype = "mesh",
	    mesh = "meseconductors_sphere_lamp_wall.obj",
	    tiles = {"meseconductors_sphere_lamp_standing.png"},
	    use_texture_alpha = true,
	    groups = {cracky=3},
	    paramtype = "light",
	    paramtype2 = "facedir",
	    --on_place = minetest.rotate_node,


	    selection_box = {
            type = "fixed",
            fixed = {-0.17,-0.26,-0.08,0.17,0.4,0.5},
	    },
	    walkable = false,
	    mesecons = {effector = {
            rules = rules_lamp_side,
	    	action_on = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:sphere_lamp_wall_on", param2 = node.param2})


		end,

		}}

})

minetest.register_node("meseconductors:sphere_lamp_wall_on", {

        description = "Sphere Lamp (On)",
	    drawtype = "mesh",
	    mesh = "meseconductors_sphere_lamp_wall.obj",
	    tiles = {"meseconductors_sphere_lamp_standing.png"},
	    use_texture_alpha = true,
	    groups = {cracky=3, not_in_creative_inventory=1},
	    paramtype = "light",
	    paramtype2 = "facedir",

        selection_box = {
            type = "fixed",
            fixed = {-0.17,-0.26,-0.08,0.17,0.4,0.5},
	    },
	    walkable = false,
	    light_source = 12,
	    --on_place = minetest.rotate_node,
        drop = "meseconductors:sphere_lamp_wall_off",
	    mesecons = {effector = {
            rules = rules_lamp_side,
	    	action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:sphere_lamp_wall_off", param2 = node.param2})

		end,

		}}

})

minetest.register_node("meseconductors:diamond_lamp_off", {

        description = "Diamond Lamp",
	    drawtype = "mesh",
	    mesh = "meseconductors_diamond_lamp.obj",
	    tiles = {"meseconductors_diamond_lamp.png"},
	    groups = {cracky=3},
	    paramtype = "light",

	    mesecons = {effector = {
            rules = rules_all,
	    	action_on = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:diamond_lamp_on", param2 = node.param2})
		end,
		}}

})

minetest.register_node("meseconductors:diamond_lamp_on", {

        description = "Diamond Lamp",
	    drawtype = "mesh",
	    mesh = "meseconductors_diamond_lamp.obj",
	    tiles = {"meseconductors_diamond_lamp_on.png"},
	    groups = {cracky=3, not_in_creative_inventory=1},
	    paramtype = "light",
	    light_source = 14,
	    drop = "meseconductors:diamond_lamp_off",

	    mesecons = {effector = {
            rules = rules_all,
	    	action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:diamond_lamp_off", param2 = node.param2})
		end,
		}}

})

minetest.register_node("meseconductors:garden_lamp_off", {

        description = "Garden Lamp",
	    drawtype = "mesh",
	    mesh = "meseconductors_garden_lamp.obj",
	    tiles = {"meseconductors_garden_lamp.png"},
	    groups = {cracky=3},
	    paramtype = "light",
	    paramtype2 = "facedir",
	    walkable = false,
	    selection_box = {
            type = "fixed",
            fixed = {-0.1500,-0.5,-0.1500,0.1500,-0.1,0.1500},
	    },

	    mesecons = {effector = {
            rules = rules_lamp_standing,
	    	action_on = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:garden_lamp_on", param2 = node.param2})
		end,
		}}

})

minetest.register_node("meseconductors:garden_lamp_on", {

        description = "Garden Lamp (on)",
	    drawtype = "mesh",
	    mesh = "meseconductors_garden_lamp.obj",
	    tiles = {"meseconductors_garden_lamp_on.png"},
	    groups = {cracky=3, not_in_creative_inventory=1},
	    paramtype = "light",
	    paramtype2 = "facedir",
	    walkable = false,
        selection_box = {
            type = "fixed",
            fixed = {-0.1500,-0.5,-0.1500,0.1500,-0.1,0.1500},
	    },
	    light_source = 12,
	    drop = "meseconductors:garden_lamp_off",

	    mesecons = {effector = {
            rules = rules_lamp_standing,
	    	action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:garden_lamp_off", param2 = node.param2})
		end,
		}}

})




minetest.register_craft({
		output = "meseconductors:mese_light_off 2",
		recipe = {
			{ "default:glass",     "default:glass",     "default:glass"},
			{ "group:wood",     "default:torch",    "group:wood"},
			{ "",     "meseconductors:lamp_controller",     ""}
		},
})

if minetest.get_modpath("homedecor") then

    minetest.register_craft({
            output = "meseconductors:sphere_lamp_standing_off 2",
            recipe = {
                { "default:glass",     "default:torch",     "default:glass"},
                { "",     "homedecor:pole_wrought_iron",    ""},
                { "homedecor:plastic_sheeting",     "meseconductors:lamp_controller",     "homedecor:plastic_sheeting"}
            },
    })
    minetest.register_craft({
            output = "meseconductors:diamond_lamp_off",
            recipe = {
                { "default:steel_ingot",     "default:diamond",     "default:obsidian_glass"},
                { "default:diamond",     "homedecor:power_crystal",    "default:diamond"},
                { "default:obsidian_glass",     "meseconductors:lamp_controller",     "default:steel_ingot"}
            },
    })
    minetest.register_craft({
            output = "meseconductors:garden_lamp_off 6",
            recipe = {
                { "default:obsidian_shard",     "homedecor:glowlight_small_cube",     "default:obsidian_shard"},
                { "",     "default:steel_ingot",    ""},
                { "",     "meseconductors:lamp_controller",     ""}
            },
    })
    minetest.register_craft({
            output = "meseconductors:sphere_lamp_standing_tall_off",
            recipe = {
                {"meseconductors:sphere_lamp_standing_off"},
                {"homedecor:pole_wrought_iron"}
            },
    })
    else
    minetest.register_craft({
            output = "meseconductors:sphere_lamp_standing_off 2",
            recipe = {
                { "default:glass",     "default:torch",     "default:glass"},
                { "",     "default:steel_ingot",    ""},
                { "default:paper",     "meseconductors:lamp_controller",     "default:paper"}
            },
    })
        minetest.register_craft({
            output = "meseconductors:sphere_lamp_standing_tall_off",
            recipe = {
                {"meseconductors:sphere_lamp_standing_off"},
                {"default:steel_ingot"}
            },
    })

    minetest.register_craft({
            output = "meseconductors:diamond_lamp_off",
            recipe = {
                { "default:steel_ingot",     "default:diamond",     "default:obsidian_glass"},
                { "default:diamond",     "default:torch",    "default:diamond"},
                { "default:obsidian_glass",     "meseconductors:lamp_controller",     "default:steel_ingot"}
            },
    })
    minetest.register_craft({
            output = "meseconductors:garden_lamp_off 6",
            recipe = {
                { "default:obsidian_shard",     "default:torch",     "default:obsidian_shard"},
                { "",     "default:steel_ingot",    ""},
                { "",     "meseconductors:lamp_controller",     ""}
            },
    })

end

minetest.register_craft({
        output = "meseconductors:sphere_lamp_wall_off",
        recipe = {
            {"default:steel_ingot", "meseconductors:sphere_lamp_standing_off"}

        },
})

function meseconductors:register_lamp(mod, node)

    if minetest.get_modpath(mod) then
	
	    local node2 = node
		if minetest.registered_nodes[mod ..":"..node] == nil then
			print("[Meseconductors] - Warning: The mod " .. mod .." has no node ".. node .. " (anymore?)")
			return false
		end
		
	    local offstate = "meseconductors:"..mod.."_"..node .. "_off"
	    local onstate  = "meseconductors:"..mod.."_"..node
	    local description = minetest.registered_nodes[mod ..":"..node].description .. " (mesecons)"
	    local description_on = minetest.registered_nodes[mod ..":"..node].description .. " (mesecons on)"

	    local tiles = minetest.registered_nodes[mod ..":"..node].tiles
		local overlay_tiles = minetest.registered_nodes[mod ..":"..node].overlay_tiles


	    local groups = table.copy(minetest.registered_nodes[mod ..":"..node].groups)
	    if node == "lava_source" then
	        groups = {snappy=3}
	        description = "Fake Lava Source"
	        description_on = "Fake Lava Source"
	    end
		if node == "corium_source" then
	        groups = {snappy=3}
	        description = "Chernobylite Lamp"
	        description_on = "Chernobylite Lamp"
	    end

		local use_texture_alpha = minetest.registered_nodes[mod ..":"..node].use_texture_alpha
		local palette = minetest.registered_nodes[mod ..":"..node].palette
		local after_place_node = minetest.registered_nodes[mod ..":"..node].after_place_node

	    local drawtype = minetest.registered_nodes[mod ..":"..node].drawtype
	    local paramtype = minetest.registered_nodes[mod ..":"..node].paramtype
	    local paramtype2 = minetest.registered_nodes[mod ..":"..node].paramtype2
	    local sounds = minetest.registered_nodes[mod ..":"..node].sounds
	    local sunlight_propagates = minetest.registered_nodes[mod ..":"..node].sunlight_propagates
	    local light_source = minetest.registered_nodes[mod ..":"..node].light_source
	    local selection_box = minetest.registered_nodes[mod ..":"..node].selection_box
	    local collision_box = minetest.registered_nodes[mod ..":"..node].collision_box
	    local node_box = minetest.registered_nodes[mod ..":"..node].node_box
	    local on_place = minetest.registered_nodes[mod ..":"..node].on_place
	    local mesh = minetest.registered_nodes[mod ..":"..node].mesh
	    local wield_image = minetest.registered_nodes[mod ..":"..node].wield_image
	    local inventory_image = minetest.registered_nodes[mod ..":"..node].inventory_image
	    local walkable = minetest.registered_nodes[mod ..":"..node].walkable





	    minetest.register_node(offstate, {

	        tiles = tiles,
			overlay_tiles = overlay_tiles,
	        description = description,
			use_texture_alpha = use_texture_alpha,
	        drawtype = drawtype,
	        paramtype = paramtype,
	        paramtype2 = paramtype2,
	        groups = groups,
	        sounds = sounds,
	        sunlight_propagates = sunlight_propagates,
	        selection_box = selection_box,
	        collision_box = collision_box,
	        node_box = node_box,
	        on_place = on_place,
	        mesh = mesh,
	        wield_image = wield_image,
	        inventory_image = inventory_image,
	        walkable = walkable,
			palette = palette,
			after_place_node = after_place_node,

	        mesecons = {effector = {
	        rules = rules_all,

			action_on = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:"..mod.."_"..node2, param2 = node.param2})
	        end,
	        }}


	    })


	    local groups_on = table.copy(groups)
	    groups_on["not_in_creative_inventory"] = 1


	    minetest.register_node(onstate, {
	        tiles = tiles,
			overlay_tiles = overlay_tiles,
	        drop = offstate,
	        description = description_on,
			use_texture_alpha = use_texture_alpha,
	        drawtype = drawtype,
	        groups = groups_on,
	        paramtype = paramtype,
	        paramtype2 = paramtype2,
	        sounds = sounds,
	        selection_box = selection_box,
	        collision_box = collision_box,
	        node_box = node_box,
	        on_place = on_place,
	        mesh = mesh,
	        wield_image = wield_image,
	        inventory_image = inventory_image,
	        sunlight_propagates = sunlight_propagates,
	        light_source = light_source,
	        walkable = walkable,
			palette = palette,
			after_place_node = after_place_node,
	        mesecons = {effector = {
	        rules = rules_all,
			action_off = function (pos, node)
			minetest.swap_node(pos, {name = "meseconductors:"..mod.."_"..node2.."_off", param2 = node.param2})
			end,
			}}
	    })	
    end	
end



meseconductors:register_lamp("default", "meselamp")
meseconductors:register_lamp("default", "mese_post_light")
meseconductors:register_lamp("ethereal", "glostone")

meseconductors:register_lamp("homedecor", "glowlight_half")
meseconductors:register_lamp("homedecor", "glowlight_quarter")
meseconductors:register_lamp("homedecor", "glowlight_small_cube")
meseconductors:register_lamp("homedecor", "lattice_lantern_large")
meseconductors:register_lamp("homedecor", "lattice_lantern_small")
meseconductors:register_lamp("homedecor", "ceiling_lamp")
meseconductors:register_lamp("default", "lava_source")
meseconductors:register_lamp("technic", "corium_source")

meseconductors:register_lamp("castle", "light")


minetest.register_craft({
		output = "meseconductors:default_lava_source_off",
		recipe = {
			{ "",     "default:obsidian_glass",     ""},
			{ "default:obsidian_glass",     "bucket:bucket_lava",    "default:obsidian_glass"},
			{ "",     "default:obsidian_glass",     ""},
			},
        replacements = {
            {"bucket:bucket_lava", "bucket:bucket_empty"}
		}
})

if minetest.get_modpath("technic") then
minetest.register_craft({
		output = "meseconductors:technic_corium_source_off",
		recipe = {
			{ "",     "technic:uranium_ingot",     ""},
			{ "technic:uranium_ingot",     "bucket:bucket_lava",    "technic:uranium_ingot"},
			{ "",     "technic:uranium_ingot",     ""},
			},
        replacements = {
            {"bucket:bucket_lava", "bucket:bucket_empty"}
		}
})

minetest.register_craft({
		output = "meseconductors:technic_corium_source_off",
		recipe = {
			{ "",     "default:glass",     ""},
			{ "default:glass",     "technic:bucket_corium",    "default:glass"},
			{ "",     "default:glass",     ""},
			},
        replacements = {
            {"bucket_corium", "bucket:bucket_empty"}
		}
})
end

minetest.register_craft({
		output = "meseconductors:default_meselamp_off",
		recipe = {
			{ "default:glass",     "meseconductors:lamp_controller"},
			{ "default:mese_crystal",     ""}

		},
})

minetest.register_craft({
	output = "meseconductors:default_mese_post_light_off",
	type = "shapeless",
	recipe = {"default:mese_post_light", "meseconductors:lamp_controller"},
})

minetest.register_craft({
		output = "meseconductors:default_mese_post_light_off",
		recipe = {
			{ "meseconductors:lamp_controller",     "default:glass",     ""},
			{ "default:mese_crystal",     "default:mese_crystal",    "default:mese_crystal"},
			{ "",     "group:wood",     ""}
		},
})

minetest.register_craft({
	output = "meseconductors:default_meselamp_off",
	type = "shapeless",
	recipe = {"default:meselamp", "meseconductors:lamp_controller"},
})

if minetest.get_modpath("ethereal") then
    minetest.register_craft({
            output = "meseconductors:ethereal_glostone_off",
            recipe = {
                { "default:torch",     "default:stone",     "dye:yellow"},
                { "",     "meseconductors:lamp_controller",    ""}
            },
    })

    minetest.register_craft({
        output = "meseconductors:ethereal_glostone_off",
        type = "shapeless",
        recipe = {"ethereal:glostone", "meseconductors:lamp_controller"},
    })
end

if minetest.get_modpath("castle") then
    minetest.register_craft({
            output = "meseconductors:castle_light_off",
            recipe = {
                { "default:stick",     "default:glass",     "default:stick"},
                { "default:glass",     "default:torch",     "default:glass"},
                { "default:stick",     "meseconductors:lamp_controller",    "default:stick"}
            },
    })

    minetest.register_craft({
        output = "meseconductors:castle_light_off",
        type = "shapeless",
        recipe = {"castle:light", "meseconductors:lamp_controller"},
    })
end

if minetest.get_modpath("homedecor") then

    minetest.register_craft({
            output = "meseconductors:homedecor_glowlight_half_off 6",
            recipe = {
                { "dye:white",     	"dye:white", 				   "dye:white"},
                { "default:glass",  "homedecor:power_crystal", "default:glass"},
                { "",     			"meseconductors:lamp_controller",	    ""}
            },
    })

    minetest.register_craft({
        output = "meseconductors:homedecor_glowlight_half_off",
        type = "shapeless",
        recipe = {"homedecor:glowlight_half", "meseconductors:lamp_controller"},
    })



    minetest.register_craft({
        output = "meseconductors:homedecor_glowlight_quarter_off",
        type = "shapeless",
        recipe = {"homedecor:glowlight_quarter", "meseconductors:lamp_controller"},
    })

    minetest.register_craft({
        output = "meseconductors:homedecor_glowlight_small_cube_off",
        type = "shapeless",
        recipe = {"homedecor:glowlight_small_cube", "meseconductors:lamp_controller"},
    })

    minetest.register_craft({
            output = "meseconductors:homedecor_glowlight_small_cube_off 8",
            recipe = {
                { "",     "", ""},
                { "default:glass",     "homedecor:power_crystal", "default:glass"},
                { "dye:white",     "meseconductors:lamp_controller", "dye:white"}
            },
    })

    minetest.register_craft({
            output = "meseconductors:homedecor_lattice_lantern_large_off 2",
            recipe = {
                { "dye:black",     "dye:yellow", "dye:black"},
                { "default:stick",     "meseconductors:lamp_controller", "default:stick"},
                { "default:stick",     "homedecor:power_crystal", "default:stick"}
            },
    })
    minetest.register_craft({
        output = "meseconductors:homedecor_lattice_lantern_large_off",
        type = "shapeless",
        recipe = {"homedecor:lattice_lantern_large", "meseconductors:lamp_controller"},
    })
    minetest.register_craft({
        output = "meseconductors:homedecor_lattice_lantern_small_off",
        type = "shapeless",
        recipe = {"homedecor:lattice_lantern_small", "meseconductors:lamp_controller"},
    })
    minetest.register_craft({
            output = "meseconductors:homedecor_lattice_lantern_small_off 8",
            recipe = {
                { "dye:black",     "dye:yellow", "dye:black"},
                { "default:stick",     "meseconductors:lamp_controller", "default:stick"},
                { "default:glass",     "homedecor:power_crystal", "default:glass"}
            },
    })
    minetest.register_craft({
            output = "meseconductors:homedecor_ceiling_lamp_off",
            recipe = {
                { "",     "chains:chain_top_brass", ""},
                { "default:glass",     "meseconductors:homedecor_glowlight_small_cube_off", "default:glass"}
            },
    })

    minetest.register_craft({
        output = "meseconductors:homedecor_ceiling_lamp_off",
        type = "shapeless",
        recipe = {"homedecor:ceiling_lamp", "meseconductors:lamp_controller"},
    })
    if minetest.get_modpath("technic") then

        minetest.register_craft({
            output = "meseconductors:homedecor_ceiling_lamp_off",
            recipe = {
                { "",     "technic:brass_ingot", ""},
                { "",     "homedecor:chainlink_brass", ""},
                { "default:glass",     "meseconductors:homedecor_glowlight_small_off", "default:glass"}
            },
    })

    end
end





