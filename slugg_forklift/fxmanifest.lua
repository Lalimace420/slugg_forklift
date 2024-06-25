fx_version 'cerulean'
games { 'gta5' }

author 'SluggDev'
description 'Capture the flag script'


shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

lua54 'yes'