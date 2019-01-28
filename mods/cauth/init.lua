cauth = colddb.Colddb("cauth")

local directory = string.format("%s/cauth", minetest.get_worldpath())

auth_handler = {
	get_auth = function(name)
		assert(type(name) == "string")
		name = name:lower()
		local data = cauth.get(name)

		if not data or data == true then
			return nil
		end
		
		local privileges = {}
		for priv, _ in pairs(data.privileges) do
			privileges[priv] = true
		end
		
		if minetest.is_singleplayer() then
			for priv, def in pairs(minetest.registered_privileges) do
				if def.give_to_singleplayer then
					privileges[priv] = true
				end
			end
		
		elseif name == minetest.settings:get("name") then
			for priv, def in pairs(minetest.registered_privileges) do
				privileges[priv] = true
			end
		end
		
		return {
			password = data.password,
			privileges = privileges,
			last_login = data.last_login,
			normal_name = data.normal_name
		}
	end,
	create_auth = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
		local oldname = name
		name = name:lower()
		minetest.log('info', "cauth authentication handler adding player '" .. name .. "'")
		cauth.set(name, {
			password = password,
			privileges = minetest.string_to_privs(minetest.settings:get("default_privs")),
			last_login = os.time(),
			normal_name = oldname})
		
		minetest.log('info', "cauth adding player '" .. oldname .. "' to index/cauth_index.cold")
		cauth.open_entry_file("cauth_index", cauth.get_or_add_tag("index", "index"))
		cauth.append_entry_file("cauth_index", oldname, "value", cauth.get_or_add_tag("index", "index"))
	end,
	delete_auth = function(name)
		assert(type(name) == 'string')
		name = name:lower()
		if cauth.file_Exists(name) then
			cauth.remove(name)
			minetest.log("info", "cauth authentication handler removing player '" .. name .. "'")
		end
	end,
	set_password = function(name, password)
		assert(type(name) == "string")
		assert(type(password) == "string")
		local oldname = name
		name = name:lower()
		local data = cauth.get(name)
		if not data then
			auth_handler.create_auth(oldname, password)
		else
			minetest.log('info', "cauth authentication handler setting password of player '" .. name .. "'")
			data.password = password
			cauth.set(name, data)
		end
		return true
	end,
	set_privileges = function(name, privileges)
		assert(type(name) == "string")
		assert(type(privileges) == "table")
		local oldname = name
		name = name:lower()
		local data = cauth.get(name)
		if not data then
			auth_handler.create_auth(oldname, 
				minetest.get_password_hash(name,
					minetest.settings:get("default_password")))
			data = cauth.get(name)
		end
		data.privileges = privileges
		cauth.set(name, data)
		minetest.notify_authentication_modified(name)
	end,
	reload = function()
		return true
	end,
	record_login = function(name)
		assert(type(name) == "string")
		name = name:lower()
		local data = cauth.get(name)
		assert(data).last_login = os.time()
		cauth.set(name, data)
	end,
	iterate = function()
		local names = {}
		for k, v in pairs(minetest.get_dir_list(directory)) do
			names[v:sub(0, v:len() - 5)] = true
		end
		return pairs(names)
	end
}

minetest.register_authentication_handler(auth_handler)

minetest.register_on_prejoinplayer(function(name, ip)
	local name_lower = name:lower()
	local data = cauth.get(name_lower)
	
	if not data then
		return
	end
	
	local normal_name = data.normal_name
	
	if normal_name ~= name then
		return string.format("\nCannot create new player called '%s'. "..
			"Another account called '%s' is already registered. "..
			"Please check the spelling if it's your account "..
			"or use a different nickname.", name, normal_name)
	end
end)

local function convert_old_auth_file()
	local path = minetest.get_worldpath() .. "/auth.txt"
	local file, errmsg = io.open(path, 'rb')
	
	if not file then
		return
	end
	
	cauth.open_entry_file("cauth_index", cauth.get_or_add_tag("index", "index"))
	
	local name_list = {}
	
	for line in file:lines() do
		if line ~= "" then
			local fields = line:split(":", true)
			local name, password, privilege_string, last_login = unpack(fields)
			name_list[#name_list + 1] = name
			last_login = tonumber(last_login)
			if name and password and privilege_string then
				minetest.log('info', "Converted '" .. name .. "' from auth.txt to cauth database.")
				cauth.set(name:lower(), {
					password = password,
					privileges = minetest.string_to_privs(privilege_string),
					last_login = last_login,
					normal_name = name})
			end
		end
	end
	
	cauth.append_entry_file("cauth_index", name_list, "value", cauth.get_or_add_tag("index", "index"))
	
	io.close(file)
	os.rename(path, minetest.get_worldpath() .. "/auth_old.txt")
end

convert_old_auth_file()
