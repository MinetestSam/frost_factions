-- License: WTFPL


rules = {}


-- Kpenguin, Thomas-S, Dragonop, stormchaser3000, Calinou, sparky/ircSparky.

local items = {
	"Welcome to Frost Factions!",
	"",
	"By playing on this server you agree to these rules:",
	"",
	"1. No hacked clients or csm that give you unfair advantage in pvp, building, mining, etc.",
	"2. Mild cursing/cussing don't curse excessively no racial slurs and no cussing anybody out,",
	"also if anyone asks you to stop please stop while they are online.",
	"3. Do not bring drama from outside servers here, please.",
	"4. No spawn killing if your at faction's spawn point (Its okay to if its a enemy spawn on your land)",
	"5. No impersonating staff or known players.",
	"6. No dating or dating role playing.",
	"7. No giving out real world personal information on any player even your self.",
	"8. Remember your account is yours. You will be held accountable for any action performed",
	"though this account even for people that you let or did not on your account.",
	"9. Griefing is allowed but not on server spawn.",
	"10. Do not ask to be staff.",
	"11. No harassing a player in chat because of their race, gender, country, religion,",
	"and political beliefs. (You can still attack them in pvp or go to war with them)",
	"12. No illegal content. (piracy, hacked client download links etc..)",
	"13. No Pornography, innuendo chat on the server also if the subject your talking about makes other ",
	"players uncomfortable stop if anyone asks you to.",
	"14. No spamming chat.",
	"15. No ban-evading.",
	"16. Do not try to change accounts when you have been muted in-game.",
	"17. Do not be rude in-chat to other players.",
	"",
	"Server staff are walrus, Coder12"}

for i = 1, #items do
	items[i] = minetest.formspec_escape(items[i])
end
rules.txt = table.concat(items, ",")

local function can_grant_interact(player)
	local name = player:get_player_name()
	return not minetest.check_player_privs(name, { interact = true }) and not minetest.check_player_privs(name, { fly = true })
end

function rules.show(player)
	local fs = "size[9,7]bgcolor[#080808BB;true]" ..
			default.gui_bg ..
			default.gui_bg_img ..
			"textlist[0.1,0.1;8.8,6.3;msg;" .. rules.txt .. ";-1;true]"

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
	if can_grant_interact(player) then
		rules.show(player)
	else
		local name = player:get_player_name()
		minetest.after(15, minetest.chat_send_player, name, "Hi " .. name .. ". You can review the server rules (updated on 2/3/19 UTC) by typing in /rules")
	end
end)

minetest.register_on_player_receive_fields(function(player, form, fields)
	if form ~= "rules:rules" then
		return
	end

	local name = player:get_player_name()
	if not can_grant_interact(player) then
		if fields.yes or fields.no then
			minetest.chat_send_player(name, "Thank you " .. name .. ". For reviewing the server rules. Stay frosty!")
			local privs = minetest.get_player_privs(name)
			privs.interact = true
			minetest.set_player_privs(name, privs)
		end
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

