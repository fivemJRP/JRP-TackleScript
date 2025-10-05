-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
local tackleSystem = 0
local anim = "mic_2_ig_11_intro_goon"
local dict = "missmic2ig_11"
local anim2 = "mic_2_ig_11_intro_p_one"
-----------------------------------------------------------------------------------------------------------------------------------------
-- Loop
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 100
		local ped = PlayerPedId()
		local pedInFront = GetPlayerPed(plyServerId ~= 0 and plyServerId or GetClosestPlayer2())
	
		
		if (IsPedRunning(ped) or IsPedSprinting(ped) and IsPedJumping(ped)) and tackleSystem <= 0 and not IsPedSwimming(ped) then
			timeDistance = 0

			if IsControlJustPressed(1,38) then
				local userStatus = nearestPlayers()
				
				if userStatus then
				TriggerServerEvent("tackle:Update",GetPlayerServerId(userStatus))
					tackleSystem = 15

					if not IsPedRagdoll(ped) then
						RequestAnimDict(dict)
						while not HasAnimDictLoaded(dict) do
							Citizen.Wait(1)
						end

						if IsEntityPlayingAnim(ped,dict,anim,3) then
							ClearPedSecondaryTask(ped)
						else
							

							vRP._playAnim(false,{"missmic2ig_11","mic_2_ig_11_intro_goon"},false)
							AttachEntityToEntity(PlayerPedId(),pedInFront,11816,0.25,0.5,0.0,0.5,0.5,180.0,false,false,false,false,2,false)
							local tackleSeconds = 3
							while tackleSeconds > 0 do
								Citizen.Wait(100)
								tackleSeconds = tackleSeconds - 1
							end
							
							
							
							Citizen.Wait(3000)
							
							vRP.stopAnim(false)							
							
							DetachEntity(ped,true,false)
							ClearPedSecondaryTask(ped)
							
						end
					end
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TACKLE:PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("tackle:Player")
AddEventHandler("tackle:Player",function()
	vRP._playAnim(false,{"missmic2ig_11","mic_2_ig_11_intro_p_one"},false)
	Citizen.Wait(3000)
	TriggerServerEvent("inventory:Cancel")
	vRP.stopAnim(false)
	SetPedToRagdoll(PlayerPedId(),5000,5000,0,0,0,0)
	tackleSystem = 3
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- loop timer 
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if tackleSystem > 0 then
			tackleSystem = tackleSystem - 1
		end

		Citizen.Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NEARESTPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function nearestPlayers()
    local ped = PlayerPedId()
    local nearestPlayer = false
    local listPlayers = GetPlayers()
    local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,1.25,0.0)

    for _,v in ipairs(listPlayers) do
        local uPlayer = GetPlayerPed(v)
        if uPlayer ~= ped and not IsPedInAnyVehicle(uPlayer) then
            local uCoords = GetEntityCoords(uPlayer)
            local distance = #(coords - uCoords)
            if distance <= 1.25 then
                nearestPlayer = v
            end
        end
    end

    return nearestPlayer
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GET CLOSEST PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function GetClosestPlayer()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped,0)
    local closestDistance = -1
    local closestPlayer = -1

    for _,v in pairs(GetActivePlayers()) do
        if GetPlayerPed(v) ~= ped then
            local targetCoords = GetEntityCoords(GetPlayerPed(v),0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"],targetCoords["y"],targetCoords["z"],pedCoords["x"],pedCoords["y"],pedCoords["z"],true)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = GetPlayerServerId(v)
                closestDistance = distance
            end
        end
    end

    return { playerid = closestPlayer, distance = closestDistance }
end

function GetClosestPlayer2()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index, value in ipairs(players) do
        local target = GetPlayerPed(value)
        if (target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"],
                plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if (closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function GetPlayers()
    local pedList = {}

    for k,v in ipairs(GetActivePlayers()) do
        table.insert(pedList,v)
    end

    return pedList
end