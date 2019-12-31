resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

client_scripts {
	'client.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/tr.lua',
	'config.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/tr.lua',
	'config.lua'
}

dependencies {
	'disc-inventoryhud',
	'mythic_notify'
}