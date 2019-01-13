local storage = minetest.get_mod_storage()

if not minetest.deserialize(storage:get_string("spawn")) then
	storage:set_string("spawn", minetest.serialize({x = 0, y = 0, z = 0}))
end

local tip = {}


minetest.register_privilege("spawn_admin", {
	description = "Can use /setspawn",
	give_to_singleplayer = false
})

minetest.register_chatcommand("spawn", {
	description = "Teleport you to the server's spawn",
	func = function(name)
		if tip[name] then
			return false, "Your already being teleported!"
		end
		local player = minetest.get_player_by_name(name)
		minetest.after(5, function(player) 
			player:set_pos(minetest.deserialize(storage:get_string("spawn"))) 
			tip[name] = nil
		end, player)
		tip[name] = true
		return true, "You will be teleported in five seconds."
	end,
})

minetest.register_chatcommand("setspawn", {
	description = "Set the server's spawn point",
	privs = {spawn_admin = true},
	func = function(name)
		name = name or "" -- fallback to blank name if nil
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		storage:set_string("spawn", minetest.serialize(pos))
		return true, "Spawn set!"
	end,
})
