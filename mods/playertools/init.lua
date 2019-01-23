-- Boilerplate to support localized strings if intllib mod is installed.
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end

--[[ informational commands ]]
minetest.register_chatcommand("whoami", {
	params = "",
	description = S("Shows your player name"),
	privs = {},
	func = function(name)
		minetest.chat_send_player(name, S("Your player name is @1.", name))
	end,
})

minetest.register_chatcommand("ip", {
	params = "",
	description = S("Shows your IP address"),
	privs = {},
	func = function(name)
		minetest.chat_send_player(name, S("Your IP address is @1.", minetest.get_player_ip(name)))
	end
})

--[[ HUD commands ]]
--[[
minetest.register_chatcommand("sethotbarsize", {
	params = S("<1...23>"),
	description = S("Sets the size of your hotbar to the provided number of slots; the number must be between 1 and 23"),
	privs = {},
	func = function(name, slots)
		if slots == "" then
			minetest.chat_send_player(name, S("You did not specify the parameter."))
			return
		end
		if type(tonumber(slots)) ~= "number" then
			minetest.chat_send_player(name, S("This is not a number."))
			return
		end
		if tonumber(slots) < 1 or tonumber(slots) > 23 then
			minetest.chat_send_player(name, S("Number of slots is out of bounds. The number of slots must be between 1 and 23."))
			return
		end
		local player = minetest.get_player_by_name(name)
		player:hud_set_hotbar_itemcount(tonumber(slots))
	end,
})
--]]

minetest.register_chatcommand("grief_check", {
	params = "[<range>] [<hours>] [<limit>]",
	description = "Check who last touched a node or a node near it"
			.. " within the time specified by <hours>. Default: range = 0,"
			.. " hours = 24 = 1d, limit = 5",
	privs = {interact=true},
	func = function(name, param)
		if not minetest.setting_getbool("enable_rollback_recording") then
			return false, "Rollback functions are disabled."
		end
		local range, hours, limit =
			param:match("(%d+) *(%d*) *(%d*)")
		range = tonumber(range) or 0
		hours = tonumber(hours) or 24
		limit = tonumber(limit) or 5
		if range > 10 then
			return false, "That range is too high! (max 10)"
		end
		if hours > 168 then
			return false, "That time limit is too high! (max 168: 7 days)"
		end
		if limit > 100 then
			return false, "That limit is too high! (max 100)"
		end
		local seconds = (hours*60)*60
		minetest.rollback_punch_callbacks[name] = function(pos, node, puncher)
			local name = puncher:get_player_name()
			minetest.chat_send_player(name, "Checking " .. minetest.pos_to_string(pos) .. "...")
			local actions = minetest.rollback_get_node_actions(pos, range, seconds, limit)			
			if not actions then
				minetest.chat_send_player(name, "Rollback functions are disabled")
				return
			end
			local num_actions = #actions
			if num_actions == 0 then
				minetest.chat_send_player(name, "Nobody has touched"
						.. " the specified location in " .. hours .. " hour(s)")
				return
			end
			local time = os.time()
			for i = num_actions, 1, -1 do
				local action = actions[i]
				minetest.chat_send_player(name,
					("%s %s %s -> %s %d seconds ago.")
						:format(
							minetest.pos_to_string(action.pos),
							action.actor,
							action.oldnode.name,
							action.newnode.name,
							time - action.time))
			end
		end

		return true, "Punch a node (range=" .. range .. ", hours="
				.. hours .. "s, limit=" .. limit .. ")"
	end,
})