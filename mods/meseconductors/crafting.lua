
    --node, mod, type
    local node_list = {
    {"wood", "default", "wood"},
    {"tree", "default", "wood"},
    {"dirt", "default", "soft"},
    {"cobble", "default", "stone"},
    {"desert_cobble", "default", "stone"},
    {"sand", "default", "soft"},
    {"desert_sand", "default", "soft"},
    {"stone", "default", "stone"},
    {"desert_stone", "default", "stone"},
    {"goldblock", "default", "block"},
    {"diamondblock", "default", "block"},
    {"jungletree", "default", "wood"},
    {"junglewood", "default", "wood"},
    {"mossycobble", "default", "stone"},
    {"obsidian", "default", "stone"},
    {"obsidian_glass", "default", "glass"},
    {"glass", "default", "glass"},
    {"sandstone", "default", "stone"},
    {"sandstonebrick", "default", "stone"},
    {"stonebrick", "default", "stone"},
    {"pine_tree", "default", "wood"},
    {"pine_wood", "default", "wood"},
    {"acacia_tree", "default", "wood"},
    {"acacia_wood", "default", "wood"},
    {"brick", "default", "stone"},
    {"cactus", "default", "wood"},
    {"aspen_tree", "default", "wood"},
    {"aspen_wood", "default", "wood"},
    {"snowblock", "default", "soft"},
    {"gravel", "default", "soft"},
    {"copperblock", "default", "block"},
    {"obsidianbrick", "default", "stone"},
    {"stone_block", "default", "stone"},
    {"desert_stone_block", "default", "stone"},
    {"obsidian_block", "default", "stone"},
    {"sandstone_block", "default", "stone"},
    {"clay", "default", "soft"},
	{"desert_stonebrick", "default", "stone"},
	{"desert_sandstone", "default", "stone"},
	{"desert_sandstone_brick", "default", "stone"},
	{"desert_sandstone_block", "default", "stone"},
	{"silver_sandstone", "default", "stone"},
	{"silver_sandstone_brick", "default", "stone"},
	{"silver_sandstone_block", "default", "stone"},
	{"silver_sand", "default", "soft"},
	{"ice", "default", "glass"},
	{"bronzeblock", "default", "block"},


    {"super_glow_glass", "moreblocks", "glass"},
    {"glow_glass", "moreblocks", "glass"},
    {"iron_stone_bricks", "moreblocks", "stone"},
    {"grey_bricks", "moreblocks", "stone"},
    {"clean_glass", "moreblocks", "glass"},
    {"cactus_brick", "moreblocks", "stone"},
    {"stone_tile", "moreblocks", "stone"},
    {"split_stone_tile", "moreblocks", "stone"},
    {"wood_tile", "moreblocks", "wood"},
    {"wood_tile_full", "moreblocks", "wood"},
    {"cactus_checker", "moreblocks", "block"},
    {"circle_stone_bricks", "moreblocks", "block"},
    {"coal_checker", "moreblocks", "block"},
    {"coal_glass", "moreblocks", "glass"},
    {"coal_stone", "moreblocks", "stone"},
    {"coal_stone_bricks", "moreblocks", "stone"},
    {"iron_checker", "moreblocks", "block"},
    {"iron_glass", "moreblocks", "glass"},
    {"iron_stone", "moreblocks", "stone"},
    {"plankstone", "moreblocks", "stone"},
    {"split_stone_tile_alt", "moreblocks", "stone"},
	{"all_faces_jungle_tree", "moreblocks", "wood"},
	{"all_faces_tree", "moreblocks", "wood"},
	{"cobble_compressed", "moreblocks", "stone"},
	{"copperpatina", "moreblocks", "block"},

    {"Adobe", "building_blocks", "soft"},
    {"hardwood", "building_blocks", "wood"},
    {"Tar", "building_blocks", "soft"},
    {"grate", "building_blocks", "block"},
    {"Marble", "building_blocks", "stone"},
    {"woodglass", "building_blocks", "glass"},
    {"smoothglass", "building_blocks", "glass"},

	--support old nodes for quartz
    {"block", "quartz", "block"},
    {"chiseled", "quartz", "block"},
    {"pillar", "quartz", "block"},

	--and new ones!!!
	{"quartzblock", "quartz", "block"},
	{"polish_quartz", "quartz", "block"},
	{"quartzbrick", "quartz", "block"},
	


    {"crystal_glass", "glooptest", "glass"},
    {"reinforced_crystal_glass", "glooptest", "glass"},
    {"akalin_crystal_glass", "glooptest", "glass"},
    {"alatro_crystal_glass", "glooptest", "glass"},
    {"arol_crystal_glass", "glooptest", "glass"},
    {"talinite_crystal_glass", "glooptest", "glass"},

    {"rainbow_block", "gloopblocks", "block"},
    {"cement", "gloopblocks", "stone"},
    {"pavement", "gloopblocks", "stone"},
    {"stone_mossy", "gloopblocks", "stone"},
	{"basalt", "gloopblocks", "stone"},
	{"cobble_road", "gloopblocks", "stone"},
	{"cobble_road_mossy", "gloopblocks", "stone"},
	{"evil_block", "gloopblocks", "block"},
	{"pumice", "gloopblocks", "stone"},
	{"scaffolding", "gloopblocks", "wood"},

    {"beech_trunk", "moretrees", "wood"},
    {"beech_planks", "moretrees", "wood"},
    {"apple_tree_trunk", "moretrees", "wood"},
    {"apple_tree_planks", "moretrees", "wood"},
    {"oak_trunk", "moretrees", "wood"},
    {"oak_planks", "moretrees", "wood"},
    {"sequoia_trunk", "moretrees", "wood"},
    {"sequoia_planks", "moretrees", "wood"},
    {"birch_trunk", "moretrees", "wood"},
    {"birch_planks", "moretrees", "wood"},
    {"palm_trunk", "moretrees", "wood"},
    {"palm_planks", "moretrees", "wood"},
    {"willow_trunk", "moretrees", "wood"},
    {"willow_planks", "moretrees", "wood"},
    {"palm_trunk", "moretrees", "wood"},
    {"palm_planks", "moretrees", "wood"},
    {"rubber_tree_trunk", "moretrees", "wood"},
    {"rubber_tree_planks", "moretrees", "wood"},
    {"fir_trunk", "moretrees", "wood"},
    {"fir_planks", "moretrees", "wood"},
    {"spruce_trunk", "moretrees", "wood"},
    {"spruce_planks", "moretrees", "wood"},
	{"cedar_trunk", "moretrees", "wood"},
    {"cedar_planks", "moretrees", "wood"},
	{"date_palm_trunk", "moretrees", "wood"},
    {"date_palm_planks", "moretrees", "wood"},
	{"poplar_trunk", "moretrees", "wood"},
    {"poplar_planks", "moretrees", "wood"},

    {"brass_block", "technic", "block"},
    {"carbon_steel_block", "technic", "block"},
    {"cast_iron_block", "technic", "block"},
    {"chromium_block", "technic", "block"},
    {"concrete", "technic", "block"},
    {"granite", "technic", "stone"},
    {"marble", "technic", "stone"},
    {"marble_bricks", "technic", "stone"},
    {"zinc_block", "technic", "block"},
    {"lead_block", "technic", "block"},
	{"blast_resistant_concrete", "technic", "block"},
	{"stainless_steel_block", "technic", "block"},
	{"uranium_block", "technic", "block"},

    {"banana_trunk", "ethereal", "wood"},
    {"banana_wood", "ethereal", "wood"},
    {"birch_trunk", "ethereal", "wood"},
    {"birch_wood", "ethereal", "wood"},
    {"bush", "ethereal", "soft"},
    {"crystal_block", "ethereal", "block"},
    {"crystal_moss", "ethereal", "soft"},
    {"dry_dirt", "ethereal", "soft"},
    {"fiery_moss", "ethereal", "soft"},
    {"frost_tree", "ethereal", "wood"},
    {"frost_wood", "ethereal", "wood"},
    {"gray_moss", "ethereal", "soft"},
    {"green_moss", "ethereal", "soft"},
    {"icebrick", "ethereal", "stone"},
    {"mushroom", "ethereal", "wood"},
    {"mushroom_moss", "ethereal", "soft"},
    {"mushroom_pore", "ethereal", "wood"},
    {"mushroom_trunk", "ethereal", "wood"},
    {"palm_trunk", "ethereal", "wood"},
    {"palm_wood", "ethereal", "wood"},
    {"redwood_trunk", "ethereal", "wood"},
    {"redwood_wood", "ethereal", "wood"},
    {"scorched_tree", "ethereal", "wood"},
    {"snowbrick", "ethereal", "stone"},
    {"willow_trunk", "ethereal", "wood"},
    {"willow_wood", "ethereal", "wood"},
    {"yellow_trunk", "ethereal", "wood"},
    {"yellow_wood", "ethereal", "wood"},

    {"mithril_block", "moreores", "block"},
    {"tin_block", "moreores", "block"},
    {"silver_block", "moreores", "block"},

    {"pavement_brick", "castle", "stone"},
    {"dungeon_stone", "castle", "stone"},
    {"rubble", "castle", "soft"},
    {"stonewall", "castle", "stone"},
    {"stonewall_corner", "castle", "stone"}
    }
local node_list2 = {
    {"dirt_with_grass", "default", "default:grass_1"},
    {"dirt_with_snow", "default", "default:snow"},
	{"dirt_with_rainforest_litter", "default", "default:junglegrass"},
    {"dirt_with_dry_grass", "default", "default:dry_grass_1"},
    {"bamboo_dirt", "ethereal", "ethereal:bamboo_leaves"},
    {"cold_dirt", "ethereal", "default:ice"},
    {"prairie_dirt", "ethereal", "group:flower"},
    {"mushroom_dirt", "ethereal", "flowers:mushroom_red"},
    {"jungle_dirt", "ethereal", "default:jungleleaves"},
    {"crystal_dirt", "ethereal", "ethereal:crystalgrass"},
    {"fiery_dirt", "ethereal", "ethereal:dry_shrub"},
    {"gray_dirt", "ethereal", "ethereal:snowygrass"},
    {"grove_dirt", "ethereal", "ethereal:fern"}
    }

function is_mod_enabled(mod_name)

    if mod_name == "default" then
        return true
    elseif mod_name == "moreblocks" and meseconductors.use_moreblocks then
        return true
    elseif mod_name == "building_blocks" and meseconductors.use_building_blocks then
        return true
    elseif mod_name == "glooptest" and meseconductors.use_glooptest then
        return true
    elseif mod_name == "gloopblocks" and meseconductors.use_gloopblocks then
        return true
    elseif mod_name == "quartz" and meseconductors.use_quartz then
        return true
    elseif mod_name == "moretrees" and meseconductors.use_moretrees then
        return true
    elseif mod_name == "technic" and meseconductors.use_technic then
        return true
    elseif mod_name == "ethereal" and meseconductors.use_ethereal then
        return true
    elseif mod_name == "moreores" and meseconductors.use_moreores then
        return true
    elseif mod_name == "castle" and meseconductors.use_castle then
        return true
    else
        return false
    end

end

for i in ipairs(node_list) do
        local node = node_list[i]
        local node_name = node[1]
        local node_mod = node[2]
        local node_type = node[3]

        if (node_type == "wood") and minetest.get_modpath(node_mod) and is_mod_enabled(node_mod) then

            minetest.register_craft({
            output = "meseconductors:".. node_mod .. "_" .. node_name,
            recipe = {
                { "",     "mesecons:mesecon",     ""},
                { "mesecons:mesecon",     node_mod .. ":" .. node_name,    "mesecons:mesecon"},
                { "",     "mesecons:mesecon",     ""}
                }
            })


        elseif (node_type == "soft") and minetest.get_modpath(node_mod) and is_mod_enabled(node_mod) then

            minetest.register_craft({
            output = "meseconductors:".. node_mod .. "_" .. node_name,
            recipe = {
                { "",     "default:mese_crystal_fragment",     ""},
                { "default:mese_crystal_fragment",     node_mod .. ":" .. node_name,    "default:mese_crystal_fragment"},
                { "",     "default:mese_crystal_fragment",     ""}
                }
            })


        elseif (node_type == "glass") and minetest.get_modpath(node_mod) and is_mod_enabled(node_mod) then

            if minetest.get_modpath("technic") then
                technic.register_alloy_recipe({
                input = {node_mod .. ":" .. node_name, "default:mese_crystal_fragment 4"},
                output = "meseconductors:".. node_mod .. "_" .. node_name,
                time = 3
                })
            else

            minetest.register_craft({
            output = "meseconductors:".. node_mod .. "_" .. node_name,
            recipe = {
                { "",     "default:mese_crystal_fragment",     ""},
                { "default:mese_crystal_fragment",     node_mod .. ":" .. node_name,    "default:mese_crystal_fragment"},
                { "",     "default:mese_crystal_fragment",     ""}
                }
            })
            end

        elseif (node_type == "stone") and minetest.get_modpath(node_mod) and is_mod_enabled(node_mod) then

            if minetest.get_modpath("technic") then
                technic.register_alloy_recipe({
                input = {node_mod .. ":" .. node_name, "default:mese_crystal"},
                output = "meseconductors:".. node_mod .. "_" .. node_name,
                time = 4
                })
            else

            minetest.register_craft({
            output = "meseconductors:".. node_mod .. "_" .. node_name,
            recipe = {
                { "default:mese_crystal_fragment",     "default:mese_crystal_fragment",     "default:mese_crystal_fragment"},
                { "default:mese_crystal_fragment",     node_mod .. ":" .. node_name,    "default:mese_crystal_fragment"},
                { "default:mese_crystal_fragment",     "default:mese_crystal_fragment",     "default:mese_crystal_fragment"}
                }
            })
            end

        elseif (node_type == "block") and minetest.get_modpath(node_mod) and is_mod_enabled(node_mod) then

            if minetest.get_modpath("technic") then
                technic.register_alloy_recipe({
                input = {node_mod .. ":" .. node_name, "default:mese_crystal 2"},
                output = "meseconductors:".. node_mod .. "_" .. node_name,
                time = 6
            })
            else

            minetest.register_craft({
            output = "meseconductors:".. node_mod .. "_" .. node_name,
            recipe = {
                { "",     "",     ""},
                { "default:mese_crystal",     node_mod .. ":" .. node_name,    "default:mese_crystal"},
                { "",     "",     ""}
                }
            })
            end
        end
end

for i in ipairs(node_list2) do
        local node = node_list2[i]
        local node_name = node[1]
        local node_mod = node[2]
        local second_element = node[3]

        if minetest.get_modpath(node_mod) and is_mod_enabled(node_mod) then

            minetest.register_craft({
                output = "meseconductors:".. node_mod .. "_" .. node_name,
                recipe = {
                    { second_element,     "default:mese_crystal_fragment",     ""},
                    { "default:mese_crystal_fragment",     "default:dirt",    "default:mese_crystal_fragment"},
                    { "",     "default:mese_crystal_fragment",     ""}
                    }
                })

            if minetest.get_modpath("ethereal") then

            minetest.register_craft({
            output = "meseconductors:".. node_mod .. "_" .. node_name,
            recipe = {
                { "",     "default:mese_crystal_fragment",     ""},
                { "default:mese_crystal_fragment",     node_mod .. ":" .. node_name,    "default:mese_crystal_fragment"},
                { "",     "default:mese_crystal_fragment",     ""}
                }
            })


            end


        end
end






