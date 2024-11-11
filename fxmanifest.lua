fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

ui_page {'web/build/index.html'}
files {
	'web/build/index.html',
	'web/build/**/*',
}

client_scripts {
    'lua/client.lua'
}

server_scripts {
    'lua/server.lua'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'lua/config.lua',
}

