fx_version "cerulean"
use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'
author 'ENT510'
version '1.0.0'


shared_scripts {
    '@ox_lib/init.lua',
    "shared/*.lua",
    'init.lua',
}

client_scripts {
    "resource/client/Dui.lua",
    "resource/client/Test.lua",
    "resource/client/api/*.lua",
    "resource/client/Internal.lua"
}

server_scripts {
    'resource/server/Editable.lua',
    'resource/server/Callback.lua',
}

files {
    'web/build/index.html',
    'web/build/**/*',
}

ui_page 'web/build/index.html'
