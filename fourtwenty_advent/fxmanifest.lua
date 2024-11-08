--[[ 
    FourTwenty Development
    discord.gg/fourtwenty
    https://fourtwenty.dev
]]

fx_version 'cerulean'
game 'gta5'

author 'FourTwenty Development'
description 'Advent Calendar System for FiveM'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/locale.lua',
    'shared/bridge.lua',
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/sounds/*.ogg'
}
