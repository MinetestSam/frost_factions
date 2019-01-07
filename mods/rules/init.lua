-- License: WTFPL


rules = {}


-- Kpenguin, Thomas-S, Dragonop, stormchaser3000, Calinou, sparky/ircSparky.

local items = {
	"Welcome to Frost Factions!",
	"",
	"By playing on this server you agree to these rules:",
	"",
	"1. No hacked clients or csm that give you unfair advantage in pvp, building, mining, etc.",
	"2. Mild cursing/cussing don't curse excesivlly no racial slurs and no cussing anybody out,",
	"also if anyone asks you to stop please stop while they are online.",
	"3. No spawn killing if your at someone's bed.",
	"4. No imperosnating staff.",
	"5. No dating or dating role playing.",
	"6. No giving out real world personal information on any player even your self.",
	"7. Griefing is allowed."}

for i = 1, #items do
	items[i] = minetest.formspec_escape(items[i])
end
rules.txt = table.concat(items, ",")

local function can_grant_interact(player)
	local name = player:get_player_name()
	return not minetest.check_player_privs(name, { interact = true }) and not minetest.check_player_privs(name, { fly = true })
end

function rules.show(player)
	local fs = "size[8,7]bgcolor[#080808BB;true]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			"textlist[0.1,0.1;7.8,6.3;msg;" .. rules.txt .. ";-1;true]"

	if not can_grant_interact(player) then
		fs = fs .. "button_exit[0.5,6;7,2;yes;Okay]"
	else
		local yes = minetest.formspec_escape("Yes, let me play!")
		local no = minetest.formspec_escape("No, get me out of here!")

		fs = fs .. "button_exit[0.5,6;3.5,2;no;" .. no .. "]"
		fs = fs .. "button_exit[4,6;3.5,2;yes;" .. yes .. "]"
	end

	minetest.show_formspec(player:get_player_name(), "rules:rules", fs)
end

minetest.register_chatcommand("rules", {
	func = function(name, param)
		if param ~= "" and
				minetest.check_player_privs(name, { kick = true }) then
			name = param
		end

		local player = minetest.get_player_by_name(name)
		if player then
			rules.show(player)
			return true, "Rules shown."
		else
			return false, "Player " .. name .. " does not exist or is not online"
		end
	end
})

minetest.register_on_joinplayer(function(player)
	local privs = minetest.get_player_privs(player:get_player_name())
	if privs.interact and privs.fly then
		privs.interact = false
		minetest.set_player_privs(player:get_player_name(), privs)
	end

	if can_grant_interact(player) then
		rules.show(player)
	end
end)

minetest.register_on_player_receive_fields(function(player, form, fields)
	if form ~= "rules:rules" then
		return
	end

	local name = player:get_player_name()
	if not can_grant_interact(player) then
		return true
	end

	if fields.msg then
		return true
	elseif not fields.yes or fields.no then
		minetest.kick_player(name,
			"You need to agree to the rules to play on this server. " ..
			"Please rejoin and confirm another time.")
		return true
	end

	local privs = minetest.get_player_privs(name)
	privs.shout = true
	privs.interact = true
	minetest.set_player_privs(name, privs)

	minetest.chat_send_player(name, "Welcome "..name.."! You have now permission to play! Stay frosty!")

	return true
end)

