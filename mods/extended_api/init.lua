modpath = minetest.get_modpath("extended_api")

extended_api = {}

dofile(string.format("%s/register.lua", modpath))
