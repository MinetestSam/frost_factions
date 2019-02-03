colddb = {}

function colddb.Colddb(dir)
	local dir = string.format("%s/%s/", minetest.get_worldpath(), dir)
	if not minetest.mkdir(dir) then
		error(string.format("%s is not a directory.", dir))
	end
	
	local self = {}
	
	local directory = dir
	local tags = {}
	local mem_pool = {}
	local mem_pool_del = {}
	local indexes_pool = {}
	local iterate_queue = {}
	local add_to_mem_pool = true
	local async = extended_api.Async()
	local path_count = {}
	
	async.priority(150, 250)
	
	-- make tables weak so the garbage-collector will remove unused data
	setmetatable(tags, {__mode = "kv"})
	setmetatable(mem_pool, {__mode = "kv"})
	setmetatable(mem_pool_del, {__mode = "kv"})
	setmetatable(indexes_pool, {__mode = "kv"})
	
	local function file_exists(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local f = io.open(string.format("%s%s%s.cold", directory, t, name), "r")
		if f ~= nil then 
			io.close(f)
			return true
		else 
			return false 
		end
		return false 
	end

	local function delete_lines_func_begin(args)
		local f = io.open(args.copyfile, "w")
		if f then
			args.file = f
			args.removedlist = {}
			return args
		end
		return false
	end

	local function delete_lines_func_i(line, i, args)
		local f = args.file
		local om = indexes_pool[args.cs]
		if om and not om.deleted_items[line] then
			f:write(string.format("\n%s", line))
		else
			args.count = args.count - 1
			args.removedlist[line] = true
		end
	end

	local function delete_lines_func_end(args)
		local cs = args.cs
		local index = indexes_pool[cs]
		if index and index.file then
			index.file:close()
			index.file = nil
			args.file:seek("set")
			args.file:write(string.format("%i", args.count))
			args.file:close()
			if args.count < 1 then
				os.remove(args.oldfile)
				os.remove(args.copyfile)
			else
				os.remove(args.oldfile)
				os.rename(args.copyfile, args.oldfile)
			end
			local pool = indexes_pool[cs]
			for i, l in pairs(args.removedlist) do
				pool.deleted_items[i] = nil
			end
			pool.deleting = false
			indexes_pool[cs] = pool
		end
		args = nil
	end

	local function iterate(func_on_iterate, end_func, count, cs, args)
		local f = indexes_pool[cs]
		local fl = f.file
		async.iterate(1, count, function(i)
			local line = fl:read("*l")
			if args.do_not_skip_removed_items or not f.deleted_items[line] then
				local ar = func_on_iterate(line, i, args)
				if ar ~= nil then
					args = ar
					return args
				end
			end
		end, function() 
			if end_func then
				end_func(args)
			end
			local iterate_queue = iterate_queue[cs]
			if iterate_queue and iterate_queue[1] then
				local copy = iterate_queue[1]
				f = indexes_pool[cs]
				if not f or not f.file then
					self.open_index_table(copy.tag_name)
					f = indexes_pool[cs]
				end
				if copy.begin_func then
					local a = copy.begin_func(copy.args)
					if a and type(a) == "table" then
						copy.args = a
					end
				end
				minetest.after(0, iterate, copy.func_on_iterate, copy.end_func, copy.count, copy.cs, copy.args)
				table.remove(iterate_queue[cs], 1)
				return false
			else
				fl:close()
				iterate_queue[cs] = nil
			end
				indexes_pool[cs].iterating = false
			return false
		end)
	end

	local function load_into_mem(name, _table, tag_name)
		if add_to_mem_pool then
			local t = ""
			if tag_name then
				t = self.get_tag(tag_name)
			end
			local cs = string.format("%s%s", t, name)
			mem_pool[cs] = {mem = _table}
		end
	end
	
	local function _remove_tag(delete_path, prev_dp)
		local pc = path_count[delete_path]
		if pc and pc > 0 then
			minetest.after(1.5, _remove_tag, delete_path)
			return
		elseif pc and pc < 1 then
			mem_pool = {}
			mem_pool_del = {}
			os.remove(delete_path)
			path_count[delete_path] = nil
			
			return
		elseif not pc then
			path_count[delete_path] = 0
		end
		
		local list = minetest.get_dir_list(delete_path)
		async.foreach(list, function(k, v)
			v = string.format("%s/%s", delete_path, v)
			local err = os.remove(v)
			if err == nil then
				minetest.after(0, _remove_tag, v, delete_path)
				path_count[delete_path] = path_count[delete_path] + 1
			end
		end, function()
			if prev_dp then
				path_count[prev_dp] = path_count[prev_dp] - 1
			end
			if pc > 0 then
				minetest.after(1.5, _remove_tag, delete_path)
			else
				mem_pool = {}
				mem_pool_del = {}
				os.remove(delete_path)
				path_count[delete_path] = nil
			end
		end)
	end
	
	self.exists = function(name, tag_name)
		return file_exists(name, tag_name)
	end
	
	self.add_tag = function(name, tag, no_new_path)
		local t = ""
		if not tags[name] then
			tags[name] = ""
		end
		if type(tag) == "table" then
			for key, value in pairs(tag) do
				t = string.format("%s%s/", t, value)
			end
		else
			t = string.format("%s/", tag)
		end
		tags[name] = string.format("%s%s", tags[name], t)
		if no_new_path then
			return
		end
		local test_path = string.format("%s%s", directory, tags[name])
		if not minetest.mkdir(test_path) then
			error(string.format("%s is not a directory.", test_path))
		end
	end
	
	self.get_tag = function(name)
		if not name then
			return ""
		end
		local tag = tags[name]
		if tag then
			return tag
		end
		return ""
	end
	
	self.get_or_add_tag = function(name, tag, no_new_path)
		if not tags[name] then
			self.add_tag(name, tag, no_new_path)
		end
		return name
	end
	
	self.remove_tag = function(name)
		if not name then
			local delete_path = directory
			local wc = delete_path:len()
			delete_path = delete_path:sub(0, wc-1)
			return
		end
		if tags[name] then
			local delete_path = string.format("%s%s", directory, tags[name])
			local wc = delete_path:len()
			delete_path = delete_path:sub(0, wc-1)
			tags[name] = nil
			local err = os.remove(delete_path)
			if err == nil then
				minetest.after(0.1, _remove_tag, delete_path)
			end
		end
	end
	
	local function delete_file(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local text = string.format("%s%s%s.cold", directory, t, name)
		
		local err, msg = os.remove(text) 
		if err == nil then 
			print(string.format("error removing db data %s error message: %s", text, msg))
		end
	end
	
	local function load_table(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local f = io.open(string.format("%s%s%s.cold", directory, t, name), "r")
		if f then
			local data = minetest.deserialize(f:read("*a"))
			f:close()
			return data
		end
		return nil
	end
	
	local function save_table(name, _table, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		minetest.log(string.format("%s%s%s.cold", directory, t, name))
		return minetest.safe_file_write(string.format("%s%s%s.cold", directory, t, name), minetest.serialize(_table))
	end

	local function save_key(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		return minetest.safe_file_write(string.format("%s%s%s.cold", directory, t, name), "")
	end

	local function load_key(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local f = io.open(string.format("%s%s%s.cold", directory, t, name), "r")
		if f then
			f:close()
			return true
		end
		return false
	end

	self.delete_entries = function(name ,_lines, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		local f = indexes_pool[cs]
		local k = type(_lines)
		if k == "string" then
			f.deleted_items[_lines] = true
		else
			for i, l in pairs(_lines) do
				f.deleted_items[i] = true
			end
		end
		if not f.deleting then
			indexes_pool[cs].deleting = false
		end
		if f and f.file and not f.deleting then
			indexes_pool[cs].deleting = true
			if f.needs_flushing == true then
				f.file:flush()
				indexes_pool[cs].needs_flushing = false
			end
			local oldfile = string.format("%s%s%s.cold", directory, t, name)
			local copyfile = string.format("%s%s%s.cold.replacer", directory, t, name)
			local args = {cs = cs, oldfile = oldfile, copyfile = copyfile, do_not_skip_removed_items = true}
			indexes_pool[cs] = f
			iterate_index_table(delete_entries_func_begin, delete_entries_func_i, delete_entries_func_end, args, tag_name)
		end
	end

	self.open_entry_file = function(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		local fs = indexes_pool[cs]
		if not fs then
			local p = string.format("%s%s%s.cold", directory, t, name)
			if not file_exists(name,tag_name) then
				local f = io.open(p, "w")
				if f then
					f:seek("set")
					f:write("0")
					f:close()
				end
			end
			local f = io.open(p, "r+")
			if f then
				indexes_pool[cs] = {file = f, needs_flushing = false, deleted_items = {}, iterating = false}
				return f
			end
			return nil
		else
			return fs.file
		end
		return nil
	end

	self.append_entry_file = function(name, key, op, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		local f = indexes_pool[cs]
		local k = type(key)
		if f and f.file and k == "string" then
			local fl = f.file
			if f.needs_flushing == true then
				fl:flush()
				f.needs_flushing = false
			end
			indexes_pool[cs].needs_flushing = true
			fl:seek("end")
			fl:write(string.format("\n%s", key))
			fl:seek("set")
			local count = tonumber(fl:read("*l"))
			count = count + 1
			fl:seek("set")
			fl:write(string.format("%i", count))
			fl:close()
		elseif f and f.file then
			local fl = f.file
			if f.needs_flushing == true then
				fl:flush()
				f.needs_flushing = false
			end
			indexes_pool[cs].needs_flushing = true
			local c = 0
			if op and op == "key" then
				for i in pairs(key) do
					fl:seek("end")
					fl:write(string.format("\n%s", i))
					c = c + 1
				end
			elseif not op or op == "value" then
				for i, j in pairs(key) do
					fl:seek("end")
					fl:write(string.format("\n%s", j))
					c = c + 1
				end
			end
			fl:seek("set")
			local count = tonumber(fl:read("*l"))
			count = count + c
			fl:seek("set")
			fl:write(string.format("%i", count))
			fl:close()
		else
			return false
		end
	end

	self.get_entry_file_count = function(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		local f = indexes_pool[cs]
		if not f or not f.file then
			self.open_entry_file(name, tag_name)
			f = indexes_pool[cs]
		end
		if f and f.file then
			local fl = f.file
			if f.needs_flushing == true then
				fl:flush()
				f.needs_flushing = false
			end
			fl:seek("set")
			local count = tonumber(fl:read("*l"))
			fl:close()
			return count
		end
		return nil
	end

	self.iterate_entry_file = function(name, begin_func, func_on_iterate, end_func, args, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		local f = indexes_pool[cs]
		if not f or not f.file then
			self.open_entry_file(tag_name)
			f = indexes_pool[cs]
		end
		if f and f.file and indexes_pool[cs].iterating == false then
			indexes_pool[cs].iterating = true
			local fl = f.file
			if f.needs_flushing == true then
				fl:flush()
				f.needs_flushing = false
			end
			-- Get count
			fl:seek("set")
			local c = tonumber(fl:read("*l"))
			if not args then
				args = {}
			end
			args.count = c
			-- Run the begin function
			if begin_func then
				local a = begin_func(args)
				if a and type(a) == "table" then
					args = a
				end
			end
			if c < 1 then
				-- If theres nothing to index then return
				end_func(args)
				indexes_pool[cs].iterating = false
				return false
			end
			-- Start iterating the index table
			iterate(func_on_iterate, end_func, c, cs, args)
		elseif f and f.file then
			local fl = f.file
			-- If its iterating some other function then add this one to the queue list
			fl:seek("set")
			local c = tonumber(fl:read("*l"))
			if c < 1 then
				-- If theres nothing to index then return
				return false
			end
			if not iterate_queue[cs] then
				iterate_queue[cs] = {}
			end
			local _table = {begin_func = begin_func, func_on_iterate = func_on_iterate, end_func = end_func, count = c, cs = cs, tag_name = tag_name, args = args}
			table.insert(iterate_queue[cs], _table)
		end
	end
	
	self.set_mem = function(name, _table, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		load_into_mem(name, _table, tag_name)
		local cs = string.format("%s%s", t, name)
		mem_pool_del[cs] = nil
	end
	
	self.save_mem = function(name, tag_name)
		local t = ""
		
		if tag_name then
			t = self.get_tag(tag_name)
		end
		
		local cs = string.format("%s%s", t, name)
		
		async.queue_task(function() 
			if mem_pool[cs] ~= nil then
				save_table(name, mem_pool[cs].mem, tag_name)
			end
		end)
		
		mem_pool_del[cs] = nil
	end

	self.set = function(name, _table, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		async.queue_task(function() 
			save_table(name, _table, tag_name)
		end)
		if add_to_mem_pool then
			load_into_mem(name, _table, tag_name)
		end
		local cs = string.format("%s%s", t, name)
		mem_pool_del[cs] = nil
	end

	self.set_key = function(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		async.queue_task(function() 
			save_key(name, tag_name)
		end)
		if add_to_mem_pool then
			load_into_mem(name, "", tag_name)
		end
		local cs = string.format("%s%s", t, name)
		mem_pool_del[cs] = nil
	end

	self.get = function(name, tag_name, callback)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		if mem_pool_del[cs] then
			if callback then
				callback(nil)
			end
			return nil
		end
		if callback then
			async.queue_task(function() 
				local pm = mem_pool[cs]
				if pm then
					return pm.mem
				else
					local _table = load_table(name, tag_name)
					if _table then
						load_into_mem(name, _table, tag_name)
						return _table
					end
				end
				mem_pool_del[cs] = true
				return nil
			end,callback)
		else
			local pm = mem_pool[cs]
			if pm then
				return pm.mem
			else
				local _table = load_table(name, tag_name)
				if _table then
					load_into_mem(name, _table, tag_name)
					return _table
				end
			end
			mem_pool_del[cs] = true
			return nil
		end
	end

	self.get_key = function(name, tag_name, callback)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		if mem_pool_del[cs] then
			if callback then
				callback(false)
			end
			return false
		end
		if callback then
			async.queue_task(function() 
				local t = ""
				if tag_name then
					t = self.get_tag(tag_name)
				end
				local pm = mem_pool[cs]
				if pm then
					return true
				else
					local bool = load_key(name, tag_name)
					if bool then
						load_into_mem(name, bool, tag_name)
						return bool
					end
				end
				mem_pool_del[cs] = true
				return nil
			end,callback)
		else
			local pm = mem_pool[cs]
			if pm then
				return true
			else
				local bool = load_key(name, tag_name)
				if bool then
					load_into_mem(name, bool, tag_name)
					return bool
				end
			end
			mem_pool_del[cs] = true
			return nil
		end
	end

	self.remove = function(name, tag_name)
		local t = ""
		if tag_name then
			t = self.get_tag(tag_name)
		end
		local cs = string.format("%s%s", t, name)
		mem_pool[cs] = nil
		mem_pool_del[cs] = true
		async.queue_task(function()
			delete_file(name, tag_name)
		end)
	end
	
	return self
end
