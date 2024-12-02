local Framework = _G.Framework
local currentGift = nil
local searchingGift = false
local giftProp = nil
local currentBlip = nil
local giftPosition = nil

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

-- Get a random location for the specified day
local function GetRandomLocation(day)
    if not Config.GiftLocations[day] then return nil end
    return Config.GiftLocations[day][math.random(#Config.GiftLocations[day])]
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

    -- Request opened doors from server
    TriggerServerEvent('fourtwenty_advent:getPlayerDoors')
end)

-- Event handler for receiving player doors from server
RegisterNetEvent('fourtwenty_advent:receivePlayerDoors')
AddEventHandler('fourtwenty_advent:receivePlayerDoors', function(playerOpenedDoors)
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
        openedDoors = playerOpenedDoors,
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
    
    local giftPos = GetRandomLocation(day)
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
    
    -- Show notification that gift has been hidden
    if Framework.CurrentFramework == 'QB' then
        Framework.Core.Functions.Notify(_U('gift_search_started'), "success")
    else
        SendNUIMessage({
            type = "showNotification",
            message = _U('gift_search_started'),
            notificationType = "success"
        })
    end
    
    SendNUIMessage({
        type = "doorOpened",
        day = day
    })
    
    currentGift = day
    giftPosition = giftPos
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
    
    -- Create the prop slightly above ground
    giftProp = CreateObject(modelHash, position.x, position.y, position.z + 0.1, false, false, true)
    
    if not DoesEntityExist(giftProp) then
        SetModelAsNoLongerNeeded(modelHash)
        return false
    end
    
    SetEntityCollision(giftProp, true, true)
    FreezeEntityPosition(giftProp, true)
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Create search area blip
    searchAreaBlip = AddBlipForRadius(position.x, position.y, position.z, Config.GiftProps.searchRadius)
    if searchAreaBlip then
        SetBlipSprite(searchAreaBlip, Config.GiftProps.blipSprite)
        SetBlipColour(searchAreaBlip, 1)
        SetBlipAlpha(searchAreaBlip, 128)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U('gift_search_area'))
        EndTextCommandSetBlipName(searchAreaBlip)
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
        AddTextComponentString(_U('gift_blip_name'))
        EndTextCommandSetBlipName(giftBlip)
    end
    
    currentGift = day
    giftPosition = position
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
    if not currentGift or not giftProp or not giftPosition then return end
    
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
        TriggerServerEvent('fourtwenty_advent:giftFound', currentGift, giftPosition)
        PlaySoundFrontend(-1, Config.Sounds.giftFound.name, Config.Sounds.giftFound.dict, false)
        
        if DoesEntityExist(giftProp) then
            DeleteEntity(giftProp)
        end
        ClearGiftBlips()
        
        currentGift = nil
        giftProp = nil
        giftPosition = nil
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
