local S = meseconductors.gettext

function meseconductors:register_wire_block(mod, node)

    if minetest.get_modpath(mod) then

		if minetest.registered_nodes[mod ..":"..node] == nil then
			print("[Meseconductors] - Warning: The mod " .. mod .." has no node ".. node .. " (anymore?)")
			return false
		end

        local offstate = "meseconductors:"..mod.."_"..node
        local onstate  = "meseconductors:"..mod.."_"..node.."_on"
        local description = minetest.registered_nodes[mod ..":"..node].description .. " (conductable)"
        local description_on = minetest.registered_nodes[mod ..":"..node].description .. " (conductable - on - NICI)"
        local tiles = minetest.registered_nodes[mod ..":"..node].tiles
		local overlay_tiles = minetest.registered_nodes[mod ..":"..node].overlay_tiles
        local groups = table.copy(minetest.registered_nodes[mod ..":"..node].groups)

        if not meseconductors.use_creative_inventory then
            groups["not_in_creative_inventory"] = 1
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





        local mesewire_rules =
        {
            {x = 1, y = 0, z = 0},
            {x =-1, y = 0, z = 0},
            {x = 0, y = 1, z = 0},
            {x = 0, y =-1, z = 0},
            {x = 0, y = 0, z = 1},
            {x = 0, y = 0, z =-1},
        }

        minetest.register_node(offstate, {
            tiles = tiles,
			overlay_tiles = overlay_tiles,
			use_texture_alpha = use_texture_alpha,
			after_place_node = after_place_node,
            description = description,
            drawtype = drawtype,
            paramtype = paramtype,
			paramtype2 = paramtype2,
            sounds = sounds,
            sunlight_propagates = sunlight_propagates,
            light_source = light_source,
            mesecons = {conductor = {
                    state = "off",
                    onstate = "meseconductors:"..mod.."_"..node.."_on",
                    rules = mesewire_rules
            }},
            groups = groups,

        })
        local textures_on = table.copy(tiles)
        if meseconductors.highlight_conducting then
            for i = 1, #textures_on, 1 do
                local t = textures_on[i]
                minetest.log("error", "type "  .. type(t))
                if type(t) == "string" then

                    textures_on[i] = t .."^[brighten"
                else
                    textures_on[i] = tiles[i]
                end
            end
        end

        local groups_on = table.copy(groups)
        --table.insert(groups_on, 1, not_in_creative_inventory)
        groups_on["not_in_creative_inventory"] = 1


        minetest.register_node(onstate, {
            tiles = textures_on,
			overlay_tiles = overlay_tiles,
			use_texture_alpha = use_texture_alpha,
			after_place_node = after_place_node,
            drop = offstate,
            description = description_on,
            drawtype = drawtype,
            paramtype = paramtype,
			paramtype2 = paramtype2,
            sounds = sounds,
            sunlight_propagates = sunlight_propagates,
            light_source = light_source,
            mesecons = {conductor = {
                    state = "on",
                    offstate = "meseconductors:"..mod.."_"..node,
                    rules = mesewire_rules
            }},
            groups = groups_on,
            --groups = {cracky=2,not_in_creative_inventory=1, mesecon = 2},
        })
    end
end
--added:
--desert_stonebrick, desert_sandstone, desert_sandstone_brick, desert_sandstone_block, silver_sandstone, silver_sandstone_brick, silver_sandstone_block, dirt_with_rainforest_litter, silver_sand, ice
local default_nodes = { "wood", "tree", "dirt", "cobble", "desert_cobble", "sand", "desert_sand",
    "stone", "desert_stone","goldblock", "diamondblock", "jungletree","junglewood", "mossycobble",
    "obsidian", "obsidian_glass", "glass", "sandstone", "sandstonebrick", "stonebrick",
    "pine_tree", "pine_wood", "acacia_tree", "acacia_wood", "brick", "cactus", "aspen_tree", "aspen_wood",
    "snowblock", "gravel", "copperblock", "obsidianbrick", "stone_block", "desert_stone_block", "desert_stonebrick", 
	"desert_sandstone", "desert_sandstone_brick", "desert_sandstone_block", "silver_sand", "silver_sandstone",
	"silver_sandstone_brick", "silver_sandstone_block", "dirt_with_rainforest_litter",
    "obsidian_block", "sandstone_block", "dirt_with_grass", "dirt_with_snow", "dirt_with_dry_grass", "clay", "ice", "bronzeblock"}

for i in ipairs(default_nodes) do

    local node = default_nodes[i]
    meseconductors:register_wire_block(
    "default",
    node)
end

if meseconductors.use_moreblocks then

    local moreblocks_nodes = { "super_glow_glass", "glow_glass", "iron_stone_bricks", "grey_bricks",
        "clean_glass", "cactus_brick", "stone_tile", "split_stone_tile", "wood_tile", "wood_tile_full",
        "cactus_checker", "circle_stone_bricks", "coal_checker", "coal_glass", "coal_stone", "coal_stone_bricks",
        "iron_checker", "iron_glass", "iron_stone", "plankstone", "split_stone_tile_alt",
		"all_faces_jungle_tree", "all_faces_tree", "cobble_compressed", "copperpatina"}

    for i in ipairs(moreblocks_nodes) do

        local node = moreblocks_nodes[i]
        meseconductors:register_wire_block(
        "moreblocks",
        node)
    end
end

if meseconductors.use_building_blocks then

    local building_blocks_nodes = { "Adobe", "hardwood", "Tar", "grate",
        "Marble", "woodglass", "smoothglass"}

    for i in ipairs(building_blocks_nodes) do

        local node = building_blocks_nodes[i]
        meseconductors:register_wire_block(
        "building_blocks",
        node)
    end
end

if meseconductors.use_quartz then

    local quartz_nodes = { "block", "chiseled", "pillar" , "polish_quartz", "quartzblock", "quartzbrick"}

    for i in ipairs(quartz_nodes) do

        local node = quartz_nodes[i]
        meseconductors:register_wire_block(
        "quartz",
        node)
    end
end

if meseconductors.use_glooptest then

    local glooptest_nodes = { "crystal_glass", "reinforced_crystal_glass", "akalin_crystal_glass",
        "alatro_crystal_glass",  "arol_crystal_glass", "talinite_crystal_glass" }

    for i in ipairs(glooptest_nodes) do

        local node = glooptest_nodes[i]
        meseconductors:register_wire_block(
        "glooptest",
        node)
    end
end

if meseconductors.use_gloopblocks then

    local gloopblocks_nodes = { "rainbow_block", "cement", "pavement",
        "stone_mossy", "basalt", "cobble_road", "cobble_road_mossy", "evil_block", "pumice", "scaffolding"}

    for i in ipairs(gloopblocks_nodes) do

        local node = gloopblocks_nodes[i]
        meseconductors:register_wire_block(
        "gloopblocks",
        node)
    end
end

if meseconductors.use_moretrees then

    local moretrees_nodes = { "beech", "apple_tree", "oak", "sequoia", "birch", "palm", "spruce", "willow", "rubber_tree", "cedar", "date_palm", "poplar"}

    for i in ipairs(moretrees_nodes) do

        local node = moretrees_nodes[i]
        meseconductors:register_wire_block(
        "moretrees",
        node .. "_trunk")

        meseconductors:register_wire_block(
        "moretrees",
        node .. "_planks")
    end
end

if meseconductors.use_technic then

    local technic_nodes = { "brass_block", "carbon_steel_block", "cast_iron_block", "chromium_block",
    "concrete", "granite", "lead_block", "marble", "marble_bricks", "zinc_block", "blast_resistant_concrete", "stainless_steel_block", "uranium_block"}

    for i in ipairs(technic_nodes) do

        local node = technic_nodes[i]
        meseconductors:register_wire_block(
        "technic",
        node)
    end

    -- not working
    --meseconductors:register_wire_block(
    --    "moretrees",
    --    "rubber_tree_trunk")
end

if meseconductors.use_ethereal then

    local ethereal_nodes = { "bamboo_dirt", "banana_trunk", "banana_wood", "birch_trunk",
    "birch_wood", "bush", "cold_dirt", "crystal_block", "crystal_dirt", "crystal_moss",
    "dry_dirt", "fiery_dirt", "fiery_moss", "frost_tree", "frost_wood", "gray_dirt", "gray_moss",
    "green_moss", "grove_dirt", "icebrick", "jungle_dirt", "mushroom", "mushroom_dirt", "mushroom_moss",
    "mushroom_pore", "mushroom_trunk", "palm_trunk", "palm_wood", "prairie_dirt", "redwood_trunk",
    "redwood_wood", "scorched_tree", "snowbrick", "willow_trunk", "willow_wood", "yellow_trunk", "yellow_wood"}


    for i in ipairs(ethereal_nodes) do

        local node = ethereal_nodes[i]
        meseconductors:register_wire_block(
        "ethereal",
        node)
    end
end

if meseconductors.use_moreores then

    local moreores_nodes = { "silver_block", "tin_block", "mithril_block"}


    for i in ipairs(moreores_nodes) do

        local node = moreores_nodes[i]
        meseconductors:register_wire_block(
        "moreores",
        node)
    end
end

if meseconductors.use_castle then

    local castle_nodes = { "pavement_brick", "dungeon_stone", "rubble", "stonewall", "stonewall_corner"}


    for i in ipairs(castle_nodes) do

        local node = castle_nodes[i]
        meseconductors:register_wire_block(
        "castle",
        node)
    end
end




