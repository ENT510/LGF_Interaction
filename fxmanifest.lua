fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

name 'LGF_Interaction'
author 'ENT510'
version '1.0.2'
description 'LGF Interaction System: A robust interaction system leveraging the Mantine UI library for a seamless user interface experience.'


files {
    'web/build/index.html',
    'web/build/**/*',
    -- function utils
    'resource/utils/shared.lua',
}

ui_page 'web/build/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*.lua',
    'init.lua',
}

client_scripts { -- interact
    -- dui mantine
    'resource/client/interact/Dui.lua',
    -- modules dui
    'resource/client/interact/api/*.lua',
    -- dev
    'resource/dev/client/*.lua',
}

server_scripts {
    'resource/server/Editable.lua',
    'resource/server/Callback.lua',
    -- dev
    -- 'resource/dev/server/*.lua',
}
