-- JGN Development - JRP Tackle Script (Server-Side)
-- Developed for JRP Server

-- Handle tackle event from tackler and notify target player
RegisterServerEvent("tackle:Update")
AddEventHandler("tackle:Update", function(targetPlayerId, tacklerSpeed, tackleDirection)
	-- Trigger tackle event on target player's client with physics data
	TriggerClientEvent("tackle:Player", targetPlayerId, tacklerSpeed, tackleDirection)
end)