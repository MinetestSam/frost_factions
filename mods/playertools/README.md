# Player tools 1.4 [playertools]
This mod adds some player-related server commands and privileges to Minetest.
Most commands are little helper tools, useful for modders and for messing
around, but they aren’t really suitable for serious gameplay. Some commands
are informational. The commands allow players to change their health, clear
their inventory, set their player physics, and other stuff.
The privileges are created for the health, physics and hotbar-related commands
and are named “`heal`”, “`physics`” and “`hotbar`”, respectively.

## List of commands
### No privileges required

* `/whoami`: Shows your name in a chat message.
* `/ip`: Shows your IP address in a chat message.
* `/pulverizeall`: Destroys all items in your player inventory and crafting grid.
* `/killme`: Kills yourself.

### “`hotbar`” privilege required

* `/sethotbarsize <1...23>`: Sets the number of slots in your hotbar (1-23).

### “`heal`” privilege and damage required

* `/sethealth <hearts>`: Sets your health to `<hearts>` hearts.
* `/sethp <hp>` Sets your health to `<hp>` HP (=half the number of “hearts”).
* `/setbreath <breath>`: Sets your breath to `<breath>` breath points.

The “`sethp`” command rounds `<hp>`.
The “`sethealth`” command rounds `<hearts>` to the nearest half, i.e:

* 2.5 → 2.5
* 2.6 → 2.5
* 2.7 → 2.5
* 2.75 → 3
* 2.8 → 3

### “`physics`” privilege required

* `/setspeed [<speed>]`: Sets your movement speed to `<speed>` (default: 1).
* `/setgravity [<gravity>]`: Sets your gravity to `<gravity>` (default: 1).
* `/setjump [<jump height>]`: Sets your jump height to `<jump height>` (default: 1).

These commands directly edit the player’s physics parameters.


## Installation
You can either install the player tools as an ordinary mod or as a builtin,
but please don’t do both. Installing it as a mod is very easy, but you have
to activate the mod explicitly for each map. Installing it as builtin is easy
and the player tools are automatically available for every server you start.

To install it as a mod, just drop this folder into the `mods/` directory of your
Minetest data folder.

To install it as builtin do this:
(For version 0.4.9)
Rename the file “`init.lua`” to “`mod_playertools.lua`” and move it to `<your Minetest installation folder>/builtin/`.
Then edit the file `<your Minetest installation folder>/builtin/builtin.lua`. Add the following line of text at the
end of the file:

    dofile(modpath.."/mod_playertools.lua")

Save the file; you’re finished! The next time you start a server the player tools are available.

## License
This mod is free software, licensed under the MIT License.
