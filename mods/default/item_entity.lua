-- mods/default/item_entity.lua

local builtin_item = minetest.registered_entities["__builtin:item"]

local time_to_live = tonumber(core.settings:get("item_entity_ttl"))
if not time_to_live then
	time_to_live = 900
end

local item = {
	set_item = function(self, itemstring)
		builtin_item.set_item(self, itemstring)

		local stack = ItemStack(itemstring)
		local itemdef = minetest.registered_items[stack:get_name()]
		if itemdef and itemdef.groups.flammable ~= 0 then
			self.flammable = itemdef.groups.flammable
		end
	end,

	burn_up = function(self)
		-- disappear in a smoke puff
		self.object:remove()
		local p = self.object:getpos()
		minetest.sound_play("default_item_smoke", {
			pos = p,
			max_hear_distance = 8,
		})
		minetest.add_particlespawner({
			amount = 3,
			time = 0.1,
			minpos = {x = p.x - 0.1, y = p.y + 0.1, z = p.z - 0.1 },
			maxpos = {x = p.x + 0.1, y = p.y + 0.2, z = p.z + 0.1 },
			minvel = {x = 0, y = 2.5, z = 0},
			maxvel = {x = 0, y = 2.5, z = 0},
			minacc = {x = -0.15, y = -0.02, z = -0.15},
			maxacc = {x = 0.15, y = -0.01, z = 0.15},
			minexptime = 4,
			maxexptime = 6,
			minsize = 5,
			maxsize = 5,
			collisiondetection = true,
			texture = "default_item_smoke.png"
		})
	end,

	on_step = function(self, dtime)
		local object = self.object
		
		self.age = self.age + dtime
		if time_to_live > 0 and self.age > time_to_live then
			self.itemstring = ''
			object:remove()
			return
		end
		local p = object:getpos()
		p.y = p.y - 0.5
		local node = core.get_node_or_nil(p)
		if node == nil then
			return
		end
		local name = node.name
		-- Delete in 'ignore' nodes
		if node and name == "ignore" then
			self.itemstring = ""
			object:remove()
			return
		end

		-- If node is nil (unloaded area), or node is not registered, or node is
		-- walkably solid and item is resting on nodebox
		local v = object:getvelocity()
		if not node or not core.registered_nodes[name] or
				core.registered_nodes[name].walkable and v.y == 0 then
			if self.physical_state then
				local own_stack = ItemStack(object:get_luaentity().itemstring)
				-- Merge with close entities of the same item
				for _, object in ipairs(core.get_objects_inside_radius(p, 0.8)) do
					local obj = object:get_luaentity()
					if obj and obj.name == "__builtin:item"
							and obj.physical_state == false then
						if self:try_merge_with(own_stack, object, obj) then
							return
						end
					end
				end
				object:setvelocity({x = 0, y = 0, z = 0})
				object:setacceleration({x = 0, y = 0, z = 0})
				self.physical_state = false
				object:set_properties({physical = false})
			end
		else
			if not self.physical_state then
				object:setvelocity({x = 0, y = 0, z = 0})
				object:setacceleration({x = 0, y = -10, z = 0})
				self.physical_state = true
				object:set_properties({physical = true})
			end
		end

		if self.flammable then
			-- flammable, check for igniters
			self.ignite_timer = (self.ignite_timer or 0) + dtime
			if self.ignite_timer > 10 then
				self.ignite_timer = 0

				if not node then
					return
				end

				-- Immediately burn up flammable items in lava
				if minetest.get_item_group(name, "lava") > 0 then
					self:burn_up()
				else
					--  otherwise there'll be a chance based on its igniter value
					local burn_chance = self.flammable
						* minetest.get_item_group(name, "igniter")
					if burn_chance > 0 and math.random(0, burn_chance) ~= 0 then
						self:burn_up()
					end
				end
			end
		end
	
		if name == "hopper:hopper" or name == "hopper:hopper_side" then
			local timer = minetest.get_node_timer(p)
			if not timer:is_started() then
				timer:start(1.0)
			end
		end
	end,
}

-- set defined item as new __builtin:item, with the old one as fallback table
setmetatable(item, builtin_item)
minetest.register_entity(":__builtin:item", item)
