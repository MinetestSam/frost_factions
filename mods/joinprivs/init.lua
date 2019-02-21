minetest.register_on_joinplayer(function(player)
    local privs = minetest.get_player_privs(player:get_player_name())
    if not privs.home or not privs.interact or not privs.shout then
        privs.home = true
        privs.interact = true
        privs.shout = true
        minetest.set_player_privs(player:get_player_name(), privs)
    end
end)
