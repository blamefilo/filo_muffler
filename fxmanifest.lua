fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'filo_muffler'
author 'filo studios.'
discord 'https://discord.gg/bErPEKvRXg'
repository 'https://github.com/blamefilo/filo_muffler'
description 'Muffler Sound Swapper'
version '1.0.1'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/sh-*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv-*.lua'
}

client_scripts {
    'client/cl-*.lua'
}

dependencies {
    'community_bridge',
    'oxmysql'
}
