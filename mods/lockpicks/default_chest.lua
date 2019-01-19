minetest.after(0, function()
	if minetest.registered_nodes["default:chest_locked"] ~= nil then
		local node_clone = {}

		for k,v in pairs(minetest.registered_nodes["default:chest_locked"]) do
			node_clone[k] = v
		end

		node_clone.can_dig = function(pos, player)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local tool = player:get_wielded_item():get_tool_capabilities()
			local lockpick = tool.groupcaps.locked
			
			if lockpick then
				if lockpick.maxlevel >= 1 then
					local wieldlevel = tool.max_drop_level
					if math.random() > math.pow(.66, wieldlevel) then
						minetest.swap_node(pos, {name = "default:chest", param2 = minetest.get_node(pos).param2})
						local meta = minetest.get_meta(pos)
						meta:set_string("infotext", "Unlocked Chest")
						meta:set_string("owner", "")
						return false
					else
						player:set_wielded_item(nil)
						minetest.chat_send_player(player:get_player_name(), "Your lockpick broke!")
					end
				end
			end
			return inv:is_empty("main") and default.can_interact_with_node(player, pos)
		end

		minetest.register_node(":default:chest_locked", node_clone)
	end
end)