local Framework = _G.Framework
local openedDoors = {}

-- Check if a value exists in a table
local function tableContains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Initialize database and framework
CreateThread(function()
    MySQL.ready(function()
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS fourtwenty_advent (
                year INT NOT NULL,
                opened_doors LONGTEXT,
                PRIMARY KEY (year)
            );
        ]])
    end)
    
    while Framework.CurrentFramework == nil do
        Wait(100)
    end
end)

-- Load saved advent calendar data on server start
MySQL.ready(function()
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_advent WHERE year = @year', {
        ['@year'] = os.date('%Y')
    }, function(results)
        if results[1] then
            openedDoors = json.decode(results[1].opened_doors) or {}
            GlobalState.openedDoors = openedDoors
        end
    end)
end)

-- Periodic data saving
CreateThread(function()
    while true do
        Wait(5 * 60 * 1000) -- Save every 5 minutes
        SaveData()
    end
end)

-- Save advent calendar data to database
function SaveData()
    MySQL.Async.execute('INSERT INTO fourtwenty_advent (year, opened_doors) VALUES (@year, @doors) ON DUPLICATE KEY UPDATE opened_doors = @doors', {
        ['@year'] = os.date('%Y'),
        ['@doors'] = json.encode(openedDoors)
    })
end

-- Check player distance from gift
function IsPlayerNearGift(source, giftCoords)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - giftCoords)
    return distance <= 3.0 -- Maximum distance of 3 meters
end

-- Check if player has enough inventory space
function HasInventorySpace(xPlayer, reward)
    if Framework.CurrentFramework == 'QB' then
        local Player = Framework.Core.Functions.GetPlayer(xPlayer.source)
        if reward.type == "item" then
            local item = Player.Functions.GetItemByName(reward.item)
            if item then
                local freeWeight = Player.Functions.GetFreeSlots()
                return freeWeight >= reward.amount
            end
        end
        return true
    elseif Framework.CurrentFramework == 'ESX' then
        if reward.type == "item" then
            local item = xPlayer.getInventoryItem(reward.item)
            if item then
                local canCarry = xPlayer.canCarryItem(reward.item, reward.amount)
                return canCarry
            end
        end
        return true
    end
    return true
end

-- Handle gift found event from client
RegisterNetEvent('fourtwenty_advent:giftFound')
AddEventHandler('fourtwenty_advent:giftFound', function(day, giftCoords)
    local source = source
    local xPlayer = Framework.GetPlayer(source)
    
    if not xPlayer then return end
    
    -- Check player distance from gift
    if not IsPlayerNearGift(source, vector3(giftCoords.x, giftCoords.y, giftCoords.z)) then
        Framework.Notify(source, _U('too_far_from_gift'), 'error')
        return
    end
    
    -- Check if player has already opened this door
    local identifier = Framework.GetIdentifier(xPlayer)
    if not openedDoors[identifier] then
        openedDoors[identifier] = {}
    end
    
    if tableContains(openedDoors[identifier], day) then
        Framework.Notify(source, _U('door_already_opened'), 'error')
        return
    end
    
    -- Process reward
    local reward = Config.Rewards[day]
    if reward then
        -- Check inventory space before giving reward
        if reward.type == "multi" then
            -- Check space for all rewards
            local hasSpace = true
            for _, subReward in ipairs(reward.rewards) do
                if not HasInventorySpace(xPlayer, subReward) then
                    hasSpace = false
                    break
                end
            end
            
            if not hasSpace then
                Framework.Notify(source, _U('inventory_full'), 'error')
                return
            end
            
            -- Give all rewards
            for _, subReward in ipairs(reward.rewards) do
                local success = ProcessSingleReward(xPlayer, subReward)
                if success then
                    TriggerClientEvent('fourtwenty_advent:receivedReward', source, subReward.notification)
                end
            end
            
            -- Record door opening after successful reward distribution
            table.insert(openedDoors[identifier], day)
            GlobalState.openedDoors = openedDoors
            TriggerClientEvent('fourtwenty_advent:receivedReward', source, reward.notification)
        else
            -- Single reward
            if not HasInventorySpace(xPlayer, reward) then
                Framework.Notify(source, _U('inventory_full'), 'error')
                return
            end
            
            local success = ProcessSingleReward(xPlayer, reward)
            if success then
                -- Record door opening after successful reward distribution
                table.insert(openedDoors[identifier], day)
                GlobalState.openedDoors = openedDoors
                TriggerClientEvent('fourtwenty_advent:receivedReward', source, reward.notification)
            end
        end
        
        -- Save progress
        SaveData()
        
        -- Log if enabled
        if Config.Logging.enabled then
            LogToDiscord(GetPlayerName(source)..' '..reward.notification)
        end
    end
end)

-- Process a single reward with error handling
function ProcessSingleReward(xPlayer, reward)
    if not xPlayer then return false end
    
    -- Wrap reward processing in pcall for error handling
    local status, err = pcall(function()
        if reward.type == "money" then
            Framework.AddMoney(xPlayer, 'cash', reward.amount)
        elseif reward.type == "black_money" then
            Framework.AddMoney(xPlayer, 'black_money', reward.amount)
        elseif reward.type == "bank" then
            Framework.AddMoney(xPlayer, 'bank', reward.amount)
        elseif reward.type == "item" then
            Framework.AddItem(xPlayer, reward.item, reward.amount)
        elseif reward.type == "weapon" then
            Framework.AddWeapon(xPlayer, reward.weapon, reward.ammo or 0)
        end
    end)
    
    if not status then
        print("Error processing reward: " .. tostring(err))
        Framework.Notify(xPlayer.source, _U('error_processing_reward'), 'error')
        return false
    end
    
    return true
end

-- Generate notification message for reward
function GenerateRewardNotification(reward)
    if reward.type == "money" then
        return _U('reward_money', reward.amount)
    elseif reward.type == "black_money" then
        return _U('reward_black_money', reward.amount)
    elseif reward.type == "bank" then
        return _U('reward_bank', reward.amount)
    elseif reward.type == "item" then
        return _U('reward_item', reward.amount, reward.item)
    elseif reward.type == "weapon" then
        return _U('reward_weapon', reward.weapon, reward.ammo or 0)
    end
end

-- Admin command to reset calendar
RegisterCommand('adventreset', function(source, args, rawCommand)
    local xPlayer = Framework.GetPlayer(source)
    
    if Framework.IsAdmin(xPlayer) then
        if args[1] == 'all' then
            -- Reset all players
            openedDoors = {}
            GlobalState.openedDoors = openedDoors
            SaveData()
            Framework.Notify(source, _U('calendar_reset'), 'success')
        else
            -- Reset specific player
            local targetIdentifier = args[1]
            if openedDoors[targetIdentifier] then
                openedDoors[targetIdentifier] = nil
                GlobalState.openedDoors = openedDoors
                SaveData()
                Framework.Notify(source, _U('calendar_reset_player'), 'success')
            end
        end
    end
end, false)

-- Discord webhook logging
function LogToDiscord(message)
    if Config.Logging.webhook then
        PerformHttpRequest(Config.Logging.webhook, function(err, text, headers) end, 'POST', json.encode({
            username = "Adventskalender",
            content = message
        }), { ['Content-Type'] = 'application/json' })
    end
end
