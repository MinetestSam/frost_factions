ColdDB
===========

ColdDB is a minetest mod that implements a serverless, asynchronous, NoSQL database engine.<br>
It provides a key or key-value based storage system using plain Lua tables.<br>

Usage
===========

Copy both *colddb.lua* and *async* files to your minetest mod or game. Copy the code from colddb's init file to your mods init file<br>
Write this code in your lua file.
1. create a directory and link it as a database.
```lua
coldbase = colddb.Colddb("mydb")
```
2. store key item(this key has no value)
```lua
coldbase.set_key("MyKey")
```
3. store key-value item
```lua
coldbase.set("MyKeyAndValue", "Hello world")
```
4. retrieve items (get_key's callback(arg) will return true, false, or nil)
```lua
coldbase.get("MyKeyAndValue", nil, function(arg)
	if arg then
		minetest.log(string.format("value:%s", arg))
	end
end)
coldbase.get_key("MyKey", nil, function(arg)
	if arg then
		minetest.log("Found key")
	else
		minetest.log("Key not found")
	end
end)
```
5. delete key(file) this function works on both keys and key-value keys.
```lua
coldbase.remove("MyKeyAndValue")
```
6. if add_to_mem_pool is true(true by default). keys are stored in a weak lua table(memory) it will be removed by the gc if its not in-use. Storing data in memory is to prevent the database from constantly loading up data from files.
```lua
coldbase.add_to_mem_pool = true
```
7. returns the amount of entries from the entry file.
```lua
coldbase.get_entry_file_count(name, tag_name)
```
8. iterates through the entry file(breaks and ends if it reaches the end of the file).
```lua
coldbase.iterate_entry_file(name, begin_func, func_on_iterate, end_func, args, tag_name)
```
9. adds a folder which can be used in other functions that have tag_name arg.
```lua
coldbase.add_tag("Extra_Folder", {"Extra", "Folder"})
```
10. returns the tag name if the tag does not exists it creates one.
```lua
coldbase.get_or_add_tag("Extra_Folder", {"Extra", "Folder"}, no_new_path)
```
11. remove tag by name.
```lua
coldbase.remove_tag("Extra_Folder")
```

Quick Look
===========

```lua
-- create an directory(watchlist) and link it as a database.
ip_db = colddb.Colddb("watchlist")

-- When ever a player join's his/her ip address is recorded to the database by player name.
minetest.register_on_prejoinplayer(function(name, ip)
	ip_db.set(name, ip, ip_db.get_or_add_tag("ips", "ips"))
end)

minetest.register_chatcommand("ip", {
	params = "<player>",
	description = "Get an player's ip address.",
    func = function(name, param)
		-- Get the ip record asynchronously.
		ip_db.get(param, ip_db.get_or_add_tag("ips", "ips"), function(record)
			-- If record is contains data send it to the player.
			if record then
				minetest.chat_send_player(name, string.format("%s:%s", param, record))
			else
				-- No record was found.
				minetest.chat_send_player(name, "Can not find ip record.")
			end
		end)
    end
})

minetest.register_chatcommand("clear", {
	params = "<player>",
	description = "Clear out the ip database.",
    func = function(name, param)
		ip_db.remove_tag(ip_db.get_or_add_tag("ips", "ips"))
		minetest.chat_send_player(name, "Ip Database Cleared!")
    end
})

```

Quick Look Notes
===========

In the example above we could also create a more complex ip database using tags. Creating tags named after the player then assigning the ip files to them.<br>
This way we could store many ips associated with the player instead of just one ip.

License
===========

ColdDB is distributed under the LGPLv2.1+ license.