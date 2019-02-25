PLAYERTAG_SIZE=0.25 --Customizes playertag size
PLAYERTAG_COLORIZE="#FFFFFF" --Playertag Color
PLAYERTAG_COLORIZE="^[colorize:"..PLAYERTAG_COLORIZE

local nametags = {}

minetest.register_entity("playertags:playertag",{initial_properties={
    max_hp=1,
    visual="sprite",
    visual_size={x=1,y=1,z=1},
    textures={"freemono_30.png"},
    selectionbox = {0,0,0,0,0,0},
},on_step=function(self,dtime)
    self.timer=self.timer+dtime
    if self.timer >= 1 then
        self.timer=0
        if not (self.owner and minetest.get_player_by_name(self.owner)) then
            self.object:remove()
        else
            self.object:set_attach(minetest.get_player_by_name(self.owner), "", {x=0,y=11,z=0}, {x=0,y=180,z=0})
        end
    end
end,
on_activate=function(self,dtime)
    self.timer=0
    self.object:set_armor_groups({immortal=1,ignore=1,do_not_delete=1})
end
})

function create_tag(player)
    local tag = minetest.add_entity(vector.add(player:get_pos(), {x=0,y=1.5,z=0}),"playertags:playertag")
    tag:get_luaentity().owner=player:get_player_name()
    tag:set_properties({visual_size = {y = PLAYERTAG_SIZE*(64/48), x = PLAYERTAG_SIZE * string.len(player:get_player_name()), z = 1}, textures = {generate_texture(player:get_player_name())}}) --Add playername
    tag:set_attach(player, "", {x=0,y=11,z=0}, {x=0,y=180,z=0})
	player:set_nametag_attributes({
		color = {a = 0, r = 0, g = 0, b = 0},
		text = " ",
	})
	nametags[player:get_player_name()] = tag
end

function remove_tag(player)
	local tag = nametags[player:get_player_name()]
	if tag then
		tag:remove()
		tag = nil
	end
	nametags[player:get_player_name()] = nil
end

minetest.register_on_joinplayer(function(player)
    create_tag(player)
end)

minetest.register_on_leaveplayer(function(player)
	remove_tag(player)
end)

function generate_texture(s)
    local r="playertag_bg.png^[resize:"..tostring(string.len(s)*48).."x64"
    for i=1,string.len(s) do
        local char="freemono_"..string.byte(s,i)..".png"
        r=r.."^[combine:64x64:"..tostring((i-1)*48)..",0".."="..char
    end
    return r..PLAYERTAG_COLORIZE
end
