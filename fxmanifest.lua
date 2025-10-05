
--shared_script "@vrp/lib/lib.lua" --Para remover esta pendencia de todos scripts, execute no console o comando "uninstall"
fx_version "bodacious"
game "gta5"
lua54 'yes'
author "luke.dev"
description "A simple tackle script."
version "1.0.0"

client_scripts {
	"@vrp/lib/utils.lua",
	"client-side/*"
}
server_scripts {
	"@vrp/lib/utils.lua",
	"server-side/*"
}              

escrow_ignore {
	"client-side/*",
	"server-side/*"
  }
dependency '/assetpacks'