local function step(name,player)
	local controls = player:get_player_control()
	if default.player_attached[name] and not player:get_attach() and
		(controls.up == true or
		controls.down == true or
		controls.left == true or
		controls.right == true or
		controls.jump == true) then
			player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			default.player_attached[name] = false
			default.player_set_animation(player, "stand", 30)
	else
		minetest.after(0.1, step, name, player)
	end
end

minetest.register_chatcommand("sit", {
	description = "Sit down",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if default.player_attached[name] then
			player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
--			player:set_physics_override(1, 1, 1)
			default.player_attached[name] = false
			default.player_set_animation(player, "stand", 30)
		else
			player:set_eye_offset({x=0, y=-7, z=2}, {x=0, y=0, z=0})
--			player:set_physics_override(0, 0, 0)
			default.player_attached[name] = true
			default.player_set_animation(player, "sit", 30)
			step(name, minetest.get_player_by_name(name))
		end
	end
})

minetest.register_chatcommand("lay", {
	description = "Lay down",
	func = function(name)
		local player = minetest.get_player_by_name(name)
		if default.player_attached[name] then
			player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
--			player:set_physics_override(1, 1, 1)
			default.player_attached[name] = false
			default.player_set_animation(player, "stand", 30)
		else
			player:set_eye_offset({x=0, y=-13, z=0}, {x=0, y=0, z=0})
--			player:set_physics_override(0, 0, 0)
			default.player_attached[name] = true
			default.player_set_animation(player, "lay", 0)
			step(name, minetest.get_player_by_name(name))
		end
	end
})
