-- JGN Development - JRP Tackle Script (Server-Side)
-- Developed for JRP Server

-- Handle tackle event from tackler and notify target player
RegisterServerEvent("tackle:Update")
AddEventHandler("tackle:Update", function(targetPlayerId)
	-- Trigger tackle event on target player's client
	TriggerClientEvent("tackle:Player", targetPlayerId)
end)