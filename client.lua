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
	
	-- Wait for animation to complete (3 seconds)
	Citizen.Wait(3000)
	
	-- Clear animation and restore collision
	ClearPedTasks(ped)
	FreezeEntityPosition(ped, false)
	SetEntityCollision(ped, true, true)
	SetPedCanRagdoll(ped, true)
	
	-- Apply directional physics if tackle direction is provided
	if tackleDirection then
		local speedMultiplier = (tacklerSpeed or 5.0) / 5.0
		local pushForce = speedMultiplier * 2.5
		ApplyForceToEntity(ped, 1, tackleDirection.x * pushForce, tackleDirection.y * pushForce, 0.5, 0.0, 0.0, 0.0, false, true, true, true, false, true)
	end
	
	-- Show impact notification
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName("~r~You've been tackled! ~o~Stunned for 10 seconds...")
	EndTextCommandThefeedPostTicker(true, true)
	
	-- PHASE 1: Keep on ground for 5 seconds (ragdoll phase)
	local groundPhaseStart = GetGameTimer()
	local groundPhaseEnd = groundPhaseStart + 5000  -- 5 seconds on ground
	
	SetPedToRagdoll(ped, 5000, 5000, 0, 0, 0, 0)
	
	Citizen.CreateThread(function()
		while GetGameTimer() < groundPhaseEnd do
			local timeLeft = groundPhaseEnd - GetGameTimer()
			
			-- Force player to stay ragdolled on ground
			if not IsPedRagdoll(ped) and timeLeft > 100 then
				SetPedToRagdoll(ped, timeLeft, timeLeft, 0, 0, 0, 0)
			end
			
			-- Disable ALL controls during ground phase
			DisableControlAction(0, 21, true)   -- Sprint
			DisableControlAction(0, 22, true)   -- Jump
			DisableControlAction(0, 23, true)   -- Enter vehicle
			DisableControlAction(0, 24, true)   -- Attack
			DisableControlAction(0, 25, true)   -- Aim
			DisableControlAction(0, 36, true)   -- Ctrl (duck)
			DisableControlAction(0, 44, true)   -- Cover
			DisableControlAction(0, 140, true)  -- Melee attack light
			DisableControlAction(0, 141, true)  -- Melee attack heavy
			DisableControlAction(0, 142, true)  -- Melee attack alternate
			DisableControlAction(0, 257, true)  -- Attack 2
			DisableControlAction(0, 263, true)  -- Melee attack
			DisableControlAction(0, 264, true)  -- Melee attack alternate
			
			Citizen.Wait(0)
		end
		
		-- PHASE 2: After getting up, stun for additional 5 seconds
		local stunPhaseStart = GetGameTimer()
		local stunPhaseEnd = stunPhaseStart + 5000  -- 5 more seconds stunned
		
		-- Notification for stun phase
		BeginTextCommandThefeedPost("STRING")
		AddTextComponentSubstringPlayerName("~o~Getting up... Still stunned for 5 seconds")
		EndTextCommandThefeedPostTicker(true, true)
		
		-- Make player walk slowly and disable actions
		while GetGameTimer() < stunPhaseEnd do
			local timeLeft = math.ceil((stunPhaseEnd - GetGameTimer()) / 1000)
			
			-- Slow movement during stun
			SetPedMoveRateOverride(ped, 0.5)  -- 50% movement speed
			
			-- Disable combat and actions during stun phase
			DisableControlAction(0, 21, true)   -- Sprint (can't sprint)
			DisableControlAction(0, 22, true)   -- Jump (can't jump)
			DisableControlAction(0, 23, true)   -- Enter vehicle
			DisableControlAction(0, 24, true)   -- Attack
			DisableControlAction(0, 25, true)   -- Aim
			DisableControlAction(0, 44, true)   -- Cover
			DisableControlAction(0, 140, true)  -- Melee attack light
			DisableControlAction(0, 141, true)  -- Melee attack heavy
			DisableControlAction(0, 142, true)  -- Melee attack alternate
			DisableControlAction(0, 257, true)  -- Attack 2
			DisableControlAction(0, 263, true)  -- Melee attack
			DisableControlAction(0, 264, true)  -- Melee attack alternate
			
			-- Show countdown every second
			if GetGameTimer() % 1000 < 50 then
				SetTextComponentFormat("STRING")
				AddTextComponentString("~o~Stunned: ~r~" .. timeLeft .. "s")
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)
			end
			
			Citizen.Wait(0)
		end
		
		-- Restore normal movement speed
		SetPedMoveRateOverride(ped, 1.0)
		
		-- Final notification
		BeginTextCommandThefeedPost("STRING")
		AddTextComponentSubstringPlayerName("~g~You've recovered from the tackle!")
		EndTextCommandThefeedPostTicker(true, true)
		PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
	end)
	
	tackleSystem = 3  -- Set short cooldown
end)

-- Event handler for permission denial
RegisterNetEvent("tackle:PermissionDenied")
AddEventHandler("tackle:PermissionDenied", function()
	-- Play error sound
	PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
	
	-- Show custom notification with VIP requirement
	SetNotificationTextEntry("STRING")
	AddTextComponentString("~r~⚠️ ACCESS DENIED~s~\n~o~JRP VIP+ Donator~s~ rank required\n~y~Visit ~b~store.JusticeRP.xyz~s~ to unlock!")
	SetNotificationMessage("CHAR_BLOCKED", "CHAR_BLOCKED", true, 1, "~r~Tackle System", "Permission Required")
	DrawNotification(false, true)
	
	-- Reset cooldown since tackle didn't execute
	tackleSystem = 0
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