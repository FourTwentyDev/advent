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
    while Framework.CurrentFramework == nil do
        Wait(100)
    end
    
    MySQL.ready(function()
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS fourtwenty_advent (
                year INT NOT NULL,
                opened_doors LONGTEXT,
                PRIMARY KEY (year)
            );
        ]])
    end)
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

-- Handle gift found event from client
RegisterNetEvent('fourtwenty_advent:giftFound')
AddEventHandler('fourtwenty_advent:giftFound', function(day)
    local source = source
    local xPlayer = Framework.GetPlayer(source)
    
    if not xPlayer then return end
    
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
        -- Record door opening
        table.insert(openedDoors[identifier], day)
        GlobalState.openedDoors = openedDoors
        
        -- Give reward to player
        GiveReward(source, reward)
        
        -- Save progress
        SaveData()
        
        -- Log if enabled
        if Config.Logging.enabled then
            LogToDiscord(GetPlayerName(source)..' '..reward.notification)
        end
    end
end)

-- Handle giving rewards to players
function GiveReward(source, reward)
    local xPlayer = Framework.GetPlayer(source)
    if not xPlayer then return end
    
    local notificationMsg

    if reward.type == "multi" then
        -- Handle multiple rewards
        for _, subReward in ipairs(reward.rewards) do
            ProcessSingleReward(xPlayer, subReward)
            TriggerClientEvent('fourtwenty_advent:receivedReward', source, subReward.notification)
        end
        notificationMsg = reward.notification
    else
        -- Handle single reward
        ProcessSingleReward(xPlayer, reward)
        notificationMsg = GenerateRewardNotification(reward)
    end
    
    if notificationMsg then
        TriggerClientEvent('fourtwenty_advent:receivedReward', source, notificationMsg)
    end
end

-- Process a single reward
function ProcessSingleReward(xPlayer, reward)
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