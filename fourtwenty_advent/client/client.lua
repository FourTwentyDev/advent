local Framework = _G.Framework
local currentGift = nil
local searchingGift = false
local giftProp = nil
local currentBlip = nil

-- Initialize framework and set up commands
CreateThread(function()
    while Framework.CurrentFramework == nil do
        Wait(100)
    end
    
    if Framework.CurrentFramework == 'QB' then
        Framework.Core.Commands.Add(Config.UI.command, _U('command_description'), {}, false, function(source)
            TriggerEvent(Config.UI.command)
        end)
    end
    
    if Framework.CurrentFramework == 'ESX' then
        Locale.CurrentLanguage = Framework.Core.GetConfig().Locale
    end
end)

-- Helper function to get a random spawn zone from config
local function GetRandomSpawnZone()
    return Config.SpawnZones[math.random(#Config.SpawnZones)]
end

-- Check if a position is clear of obstacles
local function IsPositionClear(x, y, z, radius)
    local flags = 2 + 4 + 8 + 16
    return not IsPositionOccupied(x, y, z, radius, false, true, false, false, flags)
end

-- Get the ground Z coordinate using multiple methods for accuracy
local function GetGroundZ(x, y, startZ, endZ)
    local startPosition = vector3(x, y, startZ + 0.5)
    local endPosition = vector3(x, y, endZ - 0.5)
    
    -- Try native ground check first
    local ground, groundZ = GetGroundZFor_3dCoord(x, y, startZ, false)
    if ground then
        local rayHandle = StartShapeTestRay(
            x, y, groundZ + 1.0,
            x, y, groundZ - 0.5,
            1,
            0,
            0
        )
        local retval, hit, endCoords = GetShapeTestResult(rayHandle)
        
        if hit == 1 then
            return true, endCoords.z
        end
    end
    
    -- Fallback to raycast method
    local rayHandle = StartShapeTestRay(
        startPosition.x, startPosition.y, startPosition.z,
        endPosition.x, endPosition.y, endPosition.z,
        1,
        0,
        0
    )
    
    local retval, hit, endCoords = GetShapeTestResult(rayHandle)
    
    if hit == 1 then
        local finalZ = endCoords.z
        local verifyHandle = StartShapeTestRay(
            x, y, finalZ + 0.1,
            x, y, finalZ - 0.1,
            1,
            0,
            0
        )
        local _, verifyHit = GetShapeTestResult(verifyHandle)
        
        if verifyHit == 1 then
            return true, finalZ
        end
    end
    
    return false, nil
end

-- Get a random valid position within a specified zone
function GetRandomPositionInZone(zone)
    local maxAttempts = 100
    local minDistance = 1.0
    local bestPosition = nil
    local bestScore = -1
    local playerPos = GetEntityCoords(PlayerPedId())
    
    for i = 1, maxAttempts do
        local sqrt_random = math.sqrt(math.random())
        local angle = math.random() * 2 * math.pi
        local radius = sqrt_random * zone.radius
        
        local x = zone.center.x + math.cos(angle) * radius
        local y = zone.center.y + math.sin(angle) * radius
        
        local found, groundZ = GetGroundZ(x, y, zone.maxZ + 50.0, zone.minZ - 5.0)
        
        if found and groundZ then
            if groundZ >= zone.minZ - 1.0 and groundZ <= zone.maxZ + 1.0 then
                local verifyHandle = StartShapeTestCapsule(
                    x, y, groundZ + 0.1,
                    x, y, groundZ - 0.1,
                    0.5,
                    1,
                    0,
                    7
                )
                local _, hit = GetShapeTestResult(verifyHandle)
                
                if hit == 1 and IsPositionClear(x, y, groundZ, minDistance) then
                    local currentPos = vector3(x, y, groundZ)
                    local score = 0
                    
                    local distanceFromPlayer = #(currentPos - playerPos)
                    score = score + (distanceFromPlayer / zone.radius) * 50
                    
                    local distanceFromCenter = #(currentPos - vector3(zone.center.x, zone.center.y, groundZ))
                    score = score + (distanceFromCenter / zone.radius) * 30
                    
                    score = score + math.random() * 10
                    
                    if score > bestScore then
                        local finalGround, finalZ = GetGroundZFor_3dCoord(x, y, groundZ, true)
                        if finalGround then
                            bestScore = score
                            bestPosition = vector3(x, y, finalZ)
                        end
                    end
                end
            end
        end
        
        if bestScore > 70 then
            break
        end
    end
    
    if bestPosition then
        local ground, finalZ = GetGroundZFor_3dCoord(bestPosition.x, bestPosition.y, bestPosition.z, true)
        if ground then
            bestPosition = vector3(bestPosition.x, bestPosition.y, finalZ)
        end
        return bestPosition
    else
        local ground, centerZ = GetGroundZFor_3dCoord(zone.center.x, zone.center.y, 
            (zone.maxZ + zone.minZ) / 2, true)
        
        if ground then
            return vector3(zone.center.x, zone.center.y, centerZ)
        else
            return vector3(zone.center.x, zone.center.y, zone.minZ)
        end
    end
end

-- UI Command Handler
RegisterCommand(Config.UI.command, function()
    local doorImages = {}
    
    for day, reward in pairs(Config.Rewards) do
        local imageUrl
        if reward.type == "multi" then
            if reward.rewards[1].type == "item" then
                imageUrl = string.format(Config.UI.InventoryLink, reward.rewards[1].item)
            elseif reward.rewards[1].type == "money" or reward.rewards[1].type == "bank" then
                imageUrl = string.format(Config.UI.InventoryLink, "money")
            end
        elseif reward.type == "item" then
            imageUrl = string.format(Config.UI.InventoryLink, reward.item)
        elseif reward.type == "money" or reward.type == "bank" then
            imageUrl = string.format(Config.UI.InventoryLink, "money")
        end
        
        doorImages[tostring(day)] = imageUrl
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "showUI",
        openedDoors = GlobalState.openedDoors or {},
        doorImages = doorImages,
        locale = {
            title = _U('calendar_title'),
            closeButton = _U('close_button'),
            doorLocked = _U('door_locked'),
            success = _U('success'),
            error = _U('error')
        }
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "hideUI"
    })
    cb('ok')
end)

RegisterNUICallback('openDoor', function(data, cb)
    local day = data.day
    cb('ok')
    
    local zone = GetRandomSpawnZone()
    if not zone then
        SendNUIMessage({
            type = "doorError",
            message = "Failed to find spawn zone"
        })
        return
    end
    
    local giftPos = GetRandomPositionInZone(zone)
    if not giftPos then
        SendNUIMessage({
            type = "doorError",
            message = "Failed to find valid spawn position"
        })
        return
    end
    
    local success = SpawnGiftProp(day, giftPos)
    if not success then
        SendNUIMessage({
            type = "doorError",
            message = "Failed to spawn gift"
        })
        return
    end
    
    SendNUIMessage({
        type = "doorOpened",
        day = day
    })
    
    currentGift = day
end)

-- Spawn gift prop at specified position
function SpawnGiftProp(day, position)
    if not position then return false end
    
    local propModel = Config.GiftProps.models[math.random(#Config.GiftProps.models)]
    if not propModel then return false end
    
    ClearGiftBlips()
    
    local modelHash = GetHashKey(propModel)
    RequestModel(modelHash)
    
    local timeout = 0
    local maxTimeout = 5000
    
    while not HasModelLoaded(modelHash) do
        Wait(100)
        timeout = timeout + 100
        if timeout >= maxTimeout then
            return false
        end
    end
    
    local ground, finalZ = GetGroundZFor_3dCoord(position.x, position.y, position.z, true)
    local finalPosition = ground and vector3(position.x, position.y, finalZ) or position
    
    giftProp = CreateObject(modelHash, finalPosition.x, finalPosition.y, finalPosition.z, false, false, true)
    if not DoesEntityExist(giftProp) then
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    PlaceObjectOnGroundProperly_2(giftProp)
    SetEntityCollision(giftProp, true, true)
    FreezeEntityPosition(giftProp, true)

    local propPos = GetEntityCoords(giftProp)
    local adjustHandle = StartShapeTestRay(
        propPos.x, propPos.y, propPos.z + 0.1,
        propPos.x, propPos.y, propPos.z - 0.1,
        1, 0, giftProp
    )
    local _, hit = GetShapeTestResult(adjustHandle)
    
    if hit == 1 then
        SetEntityCoords(giftProp, propPos.x, propPos.y, propPos.z + 0.05, false, false, false, false)
    end
    
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Create search area blip
    searchAreaBlip = AddBlipForRadius(position.x, position.y, position.z, Config.GiftProps.searchRadius)
    if searchAreaBlip then
        SetBlipSprite(searchAreaBlip, Config.GiftProps.blipSprite)
        SetBlipColour(searchAreaBlip, 1)
        SetBlipAlpha(searchAreaBlip, 128)
    end
    
    -- Create gift blip with offset
    local offsetX = math.random(-30, 30)
    local offsetY = math.random(-30, 30)
    giftBlip = AddBlipForCoord(position.x + offsetX, position.y + offsetY, position.z)
    if giftBlip then
        SetBlipSprite(giftBlip, Config.GiftProps.giftBlipSprite)
        SetBlipDisplay(giftBlip, 4)
        SetBlipScale(giftBlip, 1.0)
        SetBlipColour(giftBlip, 2)
        SetBlipAsShortRange(giftBlip, false)
        SetBlipRoute(giftBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U('gift_search_area'))
        EndTextCommandSetBlipName(giftBlip)
    end
    
    currentGift = day
    return true
end

-- Clear all gift-related blips
function ClearGiftBlips()
    if searchAreaBlip then
        RemoveBlip(searchAreaBlip)
        searchAreaBlip = nil
    end
    if giftBlip then
        RemoveBlip(giftBlip)
        giftBlip = nil
    end
end

-- Gift Interaction Handler
CreateThread(function()
    while true do
        Wait(0)
        
        if currentGift and giftProp then
            local playerPos = GetEntityCoords(PlayerPedId())
            local giftPos = GetEntityCoords(giftProp)
            local distance = #(playerPos - giftPos)
            
            DrawMarker(
                Config.GiftProps.markerType,
                giftPos.x, giftPos.y, giftPos.z + 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                0.5, 0.5, 0.5,
                Config.GiftProps.markerColor.r,
                Config.GiftProps.markerColor.g,
                Config.GiftProps.markerColor.b,
                Config.GiftProps.markerColor.a,
                false, true, 2, nil, nil, false
            )
            
            if distance < 2.0 then
                if not searchingGift then
                    DisplayHelpText(_U('press_to_open'))
                    
                    if IsControlJustReleased(0, 38) then
                        searchingGift = true
                        OpenGift()
                    end
                end
            end
        end
    end
end)

-- Handle gift opening process
function OpenGift()
    if not currentGift then return end
    
    TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
    
    if Framework.CurrentFramework == 'QB' then
        Framework.Core.Functions.Progressbar("opening_gift", _U('opening_gift'), Config.GiftProps.timeToSearch, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            GiftOpenComplete(false)
        end, function()
            GiftOpenComplete(true)
        end)
    elseif Framework.CurrentFramework == 'ESX' then
        if exports['progressbar'] then
            exports['progressbar']:Progress({
                name = "opening_gift",
                duration = Config.GiftProps.timeToSearch,
                label = _U('opening_gift'),
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }
            }, function(cancelled)
                GiftOpenComplete(cancelled)
            end)
        else
            Wait(Config.GiftProps.timeToSearch)
            GiftOpenComplete(false)
        end
    end
end

-- Complete gift opening process
function GiftOpenComplete(cancelled)
    if not cancelled then
        TriggerServerEvent('fourtwenty_advent:giftFound', currentGift)
        PlaySoundFrontend(-1, Config.Sounds.giftFound.name, Config.Sounds.giftFound.dict, false)
        
        if DoesEntityExist(giftProp) then
            DeleteEntity(giftProp)
        end
        ClearGiftBlips()
        
        currentGift = nil
        giftProp = nil
    end
    
    ClearPedTasks(PlayerPedId())
    searchingGift = false
end

-- Display floating help text
function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

-- Event Handler for received rewards
RegisterNetEvent('fourtwenty_advent:receivedReward')
AddEventHandler('fourtwenty_advent:receivedReward', function(notification)
    if Framework.CurrentFramework == 'QB' then
        Framework.Core.Functions.Notify(notification, "success")
    else
        SendNUIMessage({
            type = "showNotification",
            message = notification,
            notificationType = "success"
        })
    end
end)

-- Framework initialization
CreateThread(function()
    if Framework.CurrentFramework == 'QB' then
        Framework.Core.Commands.Add(Config.UI.command, _U('command_description'), {}, false, function(source)
            TriggerEvent(Config.UI.command)
        end)
    end
    
    if Framework.CurrentFramework == 'ESX' then
        CreateThread(function()
            while Framework.Core == nil do
                Wait(100)
            end
            Locale.CurrentLanguage = Framework.Core.GetConfig().Locale
        end)
    end
end)