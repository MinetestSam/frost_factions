extended_api.p_loop = {}
extended_api.step = {}

minetest.register_globalstep(function(dtime)
	local a1 = extended_api.p_loop
	local a2 = extended_api.step
	local count1 = #a1
	for _, player in pairs(minetest.get_connected_players()) do
		for i=1, count1 do
			a1[i](dtime, _, player)
		end
	end
	local count2 = #a2
	for i=1, count2 do
		a2[i](dtime)
	end
end)

function extended_api.register_playerloop(func)
	table.insert(extended_api.p_loop, func)
end

function extended_api.register_step(func)
	table.insert(extended_api.step, func)
end
