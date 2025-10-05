-- JGN Development - JRP Tackle Script
-- Developed for JRP Server

-- Tackle system cooldown timer
local tackleSystem = 0

-- Animation data for tackle system
local anim = "mic_2_ig_11_intro_goon"     -- Tackler animation
local dict = "missmic2ig_11"               -- Animation dictionary
local anim2 = "mic_2_ig_11_intro_p_one"   -- Target animation

-- Main tackle detection loop
Citizen.CreateThread(function()
	while true do
		local timeDistance = 100  -- Default wait time when not running
		local ped = PlayerPedId()
		
		-- Check if player is running/sprinting and able to tackle
		if (IsPedRunning(ped) or IsPedSprinting(ped) and IsPedJumping(ped)) and tackleSystem <= 0 and not IsPedSwimming(ped) then
			timeDistance = 0  -- Reduce wait time when ready to tackle

			-- Check for E key press (control 38)
			if IsControlJustPressed(1,38) then
				local targetPlayer = nearestPlayers()
				
				if targetPlayer then
					-- Trigger server event to notify target player
					TriggerServerEvent("tackle:Update", GetPlayerServerId(targetPlayer))
					tackleSystem = 15  -- Set cooldown timer

					-- Execute tackle animation if not already ragdolled
					if not IsPedRagdoll(ped) then
						RequestAnimDict(dict)
						while not HasAnimDictLoaded(dict) do
							Citizen.Wait(1)
						end

						if not IsEntityPlayingAnim(ped, dict, anim, 3) then
							TaskPlayAnim(ped, dict, anim, 8.0, 8.0, 3000, 0, 0, false, false, false)
							Citizen.Wait(3000)
							ClearPedTasks(ped)
						end
					end
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)
-- Event handler for when player gets tackled
RegisterNetEvent("tackle:Player")
AddEventHandler("tackle:Player", function()
	local ped = PlayerPedId()
	
	-- Load and play victim animation
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
	
	TaskPlayAnim(ped, dict, anim2, 8.0, 8.0, -1, 0, 0, false, false, false)
	Citizen.Wait(3000)
	ClearPedTasks(ped)
	
	-- Make player ragdoll for 5 seconds
	SetPedToRagdoll(ped, 5000, 5000, 0, 0, 0, 0)
	tackleSystem = 3  -- Set short cooldown
end)
-- Cooldown timer management
Citizen.CreateThread(function()
	while true do
		if tackleSystem > 0 then
			tackleSystem = tackleSystem - 1
		end
		Citizen.Wait(1000)  -- Decrease timer every second
	end
end)
-- Find nearest player within tackle range
function nearestPlayers()
    local ped = PlayerPedId()
    local nearestPlayer = false
    local listPlayers = GetPlayers()
    local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.25, 0.0)

    for _, playerId in ipairs(listPlayers) do
        local targetPed = GetPlayerPed(playerId)
        
        -- Check if target is valid (not self, not in vehicle)
        if targetPed ~= ped and not IsPedInAnyVehicle(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(coords - targetCoords)
            
            -- Check if within tackle range (1.25 units)
            if distance <= 1.25 then
                nearestPlayer = playerId
                break
            end
        end
    end

    return nearestPlayer
end

-- Get all active players in server
function GetPlayers()
    local pedList = {}
    
    for _, playerId in ipairs(GetActivePlayers()) do
        table.insert(pedList, playerId)
    end
    
    return pedList
end