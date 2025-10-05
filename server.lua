-- JGN Development - JRP Tackle Script (Server-Side)
-- Developed for JRP Server

-- Handle tackle event from tackler and notify target player
RegisterServerEvent("tackle:Update")
AddEventHandler("tackle:Update", function(targetPlayerId, tacklerSpeed, tackleDirection)
	local source = source
	
	-- Validate inputs to prevent exploits
	if not targetPlayerId or type(targetPlayerId) ~= "number" then
		return
	end
	
	if not tacklerSpeed or type(tacklerSpeed) ~= "number" then
		tacklerSpeed = 5.0  -- Default speed
	end
	
	-- Clamp speed to reasonable values (0-15 m/s)
	tacklerSpeed = math.max(0, math.min(15, tacklerSpeed))
	
	-- Check if player has permission to tackle
	if IsPlayerAceAllowed(source, "jrp.tackle") then
		-- Player has permission, trigger tackle event on target
		TriggerClientEvent("tackle:Player", targetPlayerId, tacklerSpeed, tackleDirection)
	else
		-- Player doesn't have permission, send denial notification
		TriggerClientEvent("tackle:PermissionDenied", source)
	end
end)