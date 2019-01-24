local homedb = colddb.Colddb("sethome")

sethome = {}

local function converthomes()
	local homes_file = minetest.get_worldpath() .. "/homes"
	local input = io.open(homes_file, "r")
	if not input then
		return -- no longer an error
	end

	-- Iterate over all stored positions in the format "x y z player" for each line
	for pos, name in input:read("*a"):gmatch("(%S+ %S+ %S+)%s([%w_-]+)[\r\n]") do
		homedb.set(name, pos)
	end
	input:close()
	os.rename(homes_file, minetest.get_worldpath() .. "/homes_old")
end

converthomes()

sethome.set = function(name, pos)
	local player = minetest.get_player_by_name(name)
	if not player or not pos then
		return false
	end
	player:set_attribute("sethome:home", minetest.pos_to_string(pos))

	homedb.set(name, pos)
	return true -- if the file doesn't exist - don't return an error.
end

sethome.get = function(name)
	local player = minetest.get_player_by_name(name)
	local pos = minetest.string_to_pos(player:get_attribute("sethome:home"))
	if pos then
		return pos
	end

	-- fetch old entry from storage table
	pos = homedb.get(name)
	if pos then
		return vector.new(pos)
	else
		return nil
	end
end

local tip = {}

minetest.register_privilege("home", {
	description = "Can use /sethome and /home",
	give_to_singleplayer = false
})

minetest.register_chatcommand("home", {
	description = "Teleport you to your home point",
	privs = {home = true},
	func = function(name)
		if sethome.get(name) then
			if tip[name] then
				return false, "Your already being teleported!"
			end
			local player = minetest.get_player_by_name(name)
			minetest.after(5, function(player, name) 
				if player and tip[name] then
					player:set_pos(sethome.get(name)) 
				end
				tip[name] = nil
			end, player, name)
			tip[name] = true
			return true, "You will be teleported in five seconds."
		end
		return false, "Set a home using /sethome"
	end,
})

minetest.register_chatcommand("sethome", {
	description = "Set your home point",
	privs = {home = true},
	func = function(name)
		name = name or "" -- fallback to blank name if nil
		local player = minetest.get_player_by_name(name)
		if player and sethome.set(name, player:getpos()) then
			return true, "Home set!"
		end
		return false, "Player not found!"
	end,
})

minetest.register_on_leaveplayer(
	function(player)
		local name = player:get_player_name()
		tip[name] = nil
	end
)
