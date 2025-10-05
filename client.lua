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
		if (IsPedRunning(ped) or IsPedSprinting(ped)) and tackleSystem <= 0 and not IsPedSwimming(ped) then
			timeDistance = 0  -- Reduce wait time when ready to tackle

			-- Check for E key press (control 38)
			if IsControlJustPressed(1,38) then
				local targetPlayer = nearestPlayers()
				
				if targetPlayer then
					-- Trigger server event to notify target player
					local playerSpeed = GetEntitySpeed(ped)
					local tackleDirection = GetEntityForwardVector(ped)
					TriggerServerEvent("tackle:Update", GetPlayerServerId(targetPlayer), playerSpeed, tackleDirection)
					tackleSystem = 15  -- Set cooldown timer

					-- Execute synchronized tackle animation
					if not IsPedRagdoll(ped) then
						RequestAnimDict(dict)
						while not HasAnimDictLoaded(dict) do
							Citizen.Wait(1)
						end

						if not IsEntityPlayingAnim(ped, dict, anim, 3) then
							-- Freeze both players during animation to prevent movement interference
							FreezeEntityPosition(ped, true)
							SetEntityCollision(ped, false, false)
							
							-- Play synchronized tackle animation with control flags
							TaskPlayAnim(ped, dict, anim, 8.0, 8.0, 3000, 1, 0, false, false, false)
							
							-- Play tackle sound effect (native GTA sound)
							PlaySoundFrontend(-1, "TENNIS_POINT_WON", "HUD_AWARDS", true)
							
							-- Wait for animation completion
							Citizen.Wait(3000)
							
							-- Unfreeze and restore collision
							FreezeEntityPosition(ped, false)
							SetEntityCollision(ped, true, true)
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
AddEventHandler("tackle:Player", function(tacklerSpeed, tackleDirection)
	local ped = PlayerPedId()
	
	-- Calculate tackle strength based on tackler's speed (min 3 seconds, max 7 seconds)
	local baseRagdollTime = 3000
	local speedMultiplier = (tacklerSpeed or 5.0) / 5.0  -- Normalize speed
	local ragdollDuration = math.min(7000, baseRagdollTime + (speedMultiplier * 2000))
	
	-- Load and play victim animation
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
	
	-- Freeze player to prevent movement during tackle animation
	FreezeEntityPosition(ped, true)
	SetEntityCollision(ped, false, false)
	SetPedCanRagdoll(ped, false)  -- Prevent premature ragdolling
	
	-- Play synchronized victim animation with control flags
	TaskPlayAnim(ped, dict, anim2, 8.0, 8.0, 3000, 1, 0, false, false, false)
	
	-- Impact effects for victim
	PlaySoundFrontend(-1, "PLAYER_DEATH", "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS", true)
	ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.5)  -- Screen shake on impact
	
	-- Wait for animation to complete
	Citizen.Wait(3000)
	
	-- Clear animation and restore movement
	ClearPedTasks(ped)
	FreezeEntityPosition(ped, false)
	SetEntityCollision(ped, true, true)
	SetPedCanRagdoll(ped, true)
	
	-- Apply directional physics if tackle direction is provided
	if tackleDirection then
		local pushForce = speedMultiplier * 2.5  -- Scale force by speed
		ApplyForceToEntity(ped, 1, tackleDirection.x * pushForce, tackleDirection.y * pushForce, 0.5, 0.0, 0.0, 0.0, false, true, true, true, false, true)
	end
	
	-- Make player ragdoll with variable duration based on tackle strength
	SetPedToRagdoll(ped, ragdollDuration, ragdollDuration, 0, 0, 0, 0)
	
	-- Show impact notification
	SetNotificationTextEntry("STRING")
	AddTextComponentString("~r~You've been tackled!")
	DrawNotification(false, false)
	
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