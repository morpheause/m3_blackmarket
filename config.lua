-------------------
Config = {}

Config.Locale = 'en'

-- npc settings --
Config.NpcModel = 'g_m_y_korean_02' -- npc model - more models: https://wiki.rage.mp/index.php?title=Peds -- default model: g_m_y_korean_02
Config.NpcCoords = {x = 472.37, y = -1309.84, z = 29.22}  -- npc spawn coords , , 
Config.NpcHeading = 222.26 -- set npc heading
------------------

Config.CopandDocCantAccess = true -- if you set true, police and doctor cannot access the menu
Config.DocJobName = 'ambulance' -- NOT JOB LABEL!!
Config.CopJobName = 'police' -- NOT JOB LABEL!!
Config.MinCop = 2 -- minimum number of cops required
Config.OrderTime = 1800 --second -- delivery time
Config.ChancetoReceive = 80 --% delivery chance

-- discord webhook --
Config.DiscordWebhook = 'https://discordapp.com/api/webhooks/659368698754236446/k0HubosR9D399lvvCkmdKxbQLLuqvTWufP8XZaez7i4kYTqbcLftinHgTp26C20VFU-n'
Config.WebhookName = 'Nost Blackmarket' --webhook name
Config.WebhookAvatarUrl = 'https://i.ibb.co/HHYPvfg/bigpp.png' -- webhook avatar url
---------------------

-- blackmarket location blip --
Config.EnableBlip = true
Config.BlipID = 440 -- more blips: https://wiki.gtanet.work/index.php?title=Blips
Config.BlipScale = 0.9
Config.BlipColor = 73 -- more blip color: https://wiki.gtanet.work/index.php?title=Blips
-------------------------------

-- receiver location blip --
Config.EnableReceiverBlip = true -- if you want receiver blip, set this true
Config.BlipChange = 100 --%
Config.BlipIntervalTime = 2 -- blips interval time default = 2
-- how many minutes can you see blips in the cops -- go client.lua line 260 change blip timer
----------------------------

Config.UseM3Dispatch = false -- dont touch this


--morphease#7800--

--To change add stock command permlevel or command go to server.lua line 165
