# m3_blackmarket
private blackmarket script for fivem

# Description

Fully customizable blackmarket script for fivem

# Dependencies
- mythic_notify
- disc-inventoryhud

# Installation

- Add to resource folder `[esx]`
- Execute the SQL file: `m3_blackmarket.sql`
- Customize from `config.lua`
- Start using `m3_blackmarket`

# Features

- Can be hidden on map in NPC form
- items are added in stock form
- add stock by command option
- NPC location and model can be easily configure
- can send logs to a channel via discord webhook
- easily configure the chance to take delivery or the number of police required or police notify
- police and doctor access can be disabled
- police notification can be easily switched on and off
- 2 language option (en, tr)

# Notes

- To change add stock command permlevel or command go to server.lua line 165
- weapons must be changed to item for it to work. If you have manuelly changed, you can delete the disc-inventoryhud section from the dependencies section of the _resource.lua.
- To change bomb search command go to client.lua line 230
- If you use kashacters add this code to kashacters IdentifierTables `{table = "m3_blackmarket_orders", column = "identifier"}`

# Contact
you can pr for features that can be added or for errors.

- Discord: morpheause#7800
- nost roleplay: https://discordapp.com/invite/BbQUCTU
