resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description '99kr-shops'

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/tr.lua',
    'config.lua',
    'client/main.lua',
    'client/shop.lua',
}

server_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'locales/tr.lua',
    'config.lua',
    'server/main.lua',
}

dependencies {
    'es_extended',
    'esx_menu_default'
}