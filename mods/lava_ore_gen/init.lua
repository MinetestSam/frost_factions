local ore_nodes = {}
local ore_rarities = {}
local ore_r_nodes = {}
local count = 0
local r_count = 0
local blacklist = {}

function add_ore(name)
	if minetest.registered_nodes[name] then
		table.insert(ore_nodes, name)
		count = count + 1
	end
end

function add_ores()
	for i,v in next,minetest.registered_ores do
		local ore_name = minetest.registered_ores[i].ore
		if string.match(ore_name,":stone_with_") or string.match(ore_name,":mineral_") then
			if check_blacklist(ore_name) == false then
				add_ore(ore_name)
			end
		end
	end
end

function get_rarities()
	for i,v in next,ore_nodes do
		for j,n in next,minetest.registered_ores do
			if v == n.ore then
				table.insert(ore_rarities, math.floor(n.clust_scarcity / n.clust_size))
				table.insert(ore_r_nodes, v)
				r_count = r_count + 1
			end
		end
	end
end

function _copy(node)
	local copy = {}
	for i,v in next, node do
		copy[i] = v
	end
	return copy
end

function check_blacklist(s)
	local r = false
	for i,v in next,blacklist do
		if v == s then
			r = true
		end
	end
	return r
end

-- Get ores --
add_ores()

if count > 0 then
	-- ore rarities --
	get_rarities()
	
	-- null --
	ore_nodes = nil
	count = nil
	
	local clonenodeForLava = {}
	for k,v in pairs(minetest.registered_nodes["default:stone"]) do clonenodeForLava[k] = v end
	clonenodeForLava.groups = {cracky = 3, stone = 1, not_in_creative_inventory = 1}
	clonenodeForLava.description = "Heated Stone"
	clonenodeForLava.tiles = {"default_stone.png^[colorize:red:20"}
	clonenodeForLava.paramtype = "light"
	clonenodeForLava.light_source = 4
	clonenodeForLava.on_timer = function(pos)
		local i = minetest.find_node_near(pos, 1, {"group:lava"})
		if i then
			minetest.after(0, 
			function(pos)
				local _or = {}
				local r = math.random(1,r_count)
				local ore_test = ore_rarities[r]
				local ore_common = 1
				for i,v in next,ore_rarities do
					r = math.random(1,r_count)
					ore_test = ore_rarities[r]
					_or[i] = ore_rarities[i] - math.floor(math.random((ore_test / (math.random(0,ore_test)*5))))
				end
				r = math.random(1,r_count)
				ore_test = _or[r]
				for i,v in next, _or do
					if ore_test > v then
						ore_test = v
						ore_common = i
						i = 1
					end
				end
				local ore_name = ore_r_nodes[ore_common]
				minetest.swap_node(pos, {name = ore_name})
			end,pos)
		else
			i = minetest.find_node_near(pos, 1, {"group:water","group:liquid"})
			minetest.after(0, 
			function(pos)
				minetest.set_node(pos, {name="default:stone"})
			end,pos)
		end
	end
	minetest.register_node("lava_ore_gen:stone_hot",clonenodeForLava)
	
	-- make stone floodable --
	local node = {}
	for k,v in pairs(minetest.registered_nodes["default:stone"]) do node[k] = v end
	node.floodable = true
	node.on_flood = function(pos, oldnode, newnode)
		local def = minetest.registered_items[newnode.name]
		if (def and def.groups and def.groups.lava and def.groups.lava > 0) then
		minetest.after(0, 
		function(pos)
			minetest.set_node(pos, {name="lava_ore_gen:stone_hot"})
			minetest.get_node_timer(pos):start(20+math.random(1, 3600))
		end,pos)
		else
			return true
		end
		return false
	end
	minetest.register_node(":default:stone",node)
end