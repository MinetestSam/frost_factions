meseconductors = {}

local modpath=minetest.get_modpath("meseconductors")

local worldpath=minetest.get_worldpath()
dofile(modpath.."/default_settings.txt")

if io.open(worldpath.."/meseconductors_settings.txt","r") == nil then
    io.input(modpath.."/default_settings.txt")
    io.output(worldpath.."/meseconductors_settings.txt")

    local size = 2^13 -- good buffer size (8K)
    while true do
        local block = io.read(size)
        if not block then
            io.close()
            break
        end
        io.write(block)
    end
else
    dofile(worldpath.."/meseconductors_settings.txt")
end


local S -- Load translation library if intllib is installed:
if intllib then
    S = intllib.Getter(minetest.get_current_modname())
else
    S = function(s) return s end
end
meseconductors.gettext = S

dofile(minetest.get_modpath("meseconductors").."/lamps.lua")
dofile(minetest.get_modpath("meseconductors").."/nodes.lua")
dofile(minetest.get_modpath("meseconductors").."/crafting.lua")
dofile(minetest.get_modpath("meseconductors").."/lightstones.lua")

