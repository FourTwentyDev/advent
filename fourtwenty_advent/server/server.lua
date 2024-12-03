local Framework = _G.Framework
local openedDoors = {}

-- Enhanced logging function
local function Log(type, message, data)
    local colors = {
        INFO = '^5',
        SUCCESS = '^2',
        WARNING = '^3',
        ERROR = '^1'
    }
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local colorCode = colors[type] or '^7'
    local logMessage = string.format('[%s] %s[Advent Calendar]^7 %s', timestamp, colorCode, message)
    --print(logMessage)
    
    if data then
        --print('^7[Advent Calendar Data]', json.encode(data, {indent = true}))
    end
end

-- Initialize database and framework
CreateThread(function()
    MySQL.ready(function()
        Log('INFO', 'Database connection established')
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS fourtwenty_advent (
                identifier VARCHAR(50) NOT NULL,
                year INT NOT NULL,
                opened_doors JSON,
                PRIMARY KEY (identifier, year)
            );
        ]])
    end)
    
    while Framework.CurrentFramework == nil do
        Wait(100)
    end
    Log('INFO', 'Framework initialized: ' .. tostring(Framework.CurrentFramework))
end)

-- Load saved advent calendar data on server start
MySQL.ready(function()
    Log('INFO', 'Loading saved advent calendar data')
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_advent WHERE year = @year', {
        ['@year'] = os.date('%Y')
    }, function(results)
        if results then
            for _, row in ipairs(results) do
                openedDoors[row.identifier] = json.decode(row.opened_doors) or {}
            end
            Log('SUCCESS', 'Loaded advent calendar data', {playerCount = #results})
        end
    end)
end)

-- Save data for a specific player
function SavePlayerData(identifier)
    if not identifier or not openedDoors[identifier] then 
        Log('WARNING', 'Failed to save player data - Invalid identifier or no data', {identifier = identifier})
        return 
    end
    
    Log('INFO', 'Saving player data', {identifier = identifier, doorCount = #openedDoors[identifier]})
    MySQL.Async.execute('INSERT INTO fourtwenty_advent (identifier, year, opened_doors) VALUES (@identifier, @year, @doors) ON DUPLICATE KEY UPDATE opened_doors = @doors', {
        ['@identifier'] = identifier,
        ['@year'] = os.date('%Y'),
        ['@doors'] = json.encode(openedDoors[identifier])
    })
end

-- Periodic data saving for all players
CreateThread(function()
    while true do
        Wait(60 * 1000)
        local playerCount = 0
        for identifier, _ in pairs(openedDoors) do
            SavePlayerData(identifier)
            playerCount = playerCount + 1
        end
        Log('INFO', 'Periodic save completed', {savedPlayers = playerCount})
    end
end)

-- Check if a value exists in a table
local function tableContains(table, value)
    Log('INFO', 'Checking door access', {doors = table, checkingDay = value})
    
    for _, v in ipairs(table) do
        if v == value then
            Log('WARNING', 'Door already opened', {day = value})
            return true
        end
    end
    
    Log('SUCCESS', 'Door available', {day = value})
    return false
end

-- Check player distance from gift
function IsPlayerNearGift(source, giftCoords)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - giftCoords)
    local isNear = distance <= 3.0
    
    Log('INFO', 'Distance check', {
        player = GetPlayerName(source),
        distance = distance,
        isNear = isNear,
        playerCoords = {x = playerCoords.x, y = playerCoords.y, z = playerCoords.z},
        giftCoords = {x = giftCoords.x, y = giftCoords.y, z = giftCoords.z}
    })
    
    return isNear
end

-- Check if player has enough inventory space
function HasInventorySpace(xPlayer, reward)
    Log('INFO', 'Checking inventory space', {
        player = GetPlayerName(xPlayer.source),
        reward = reward
    })
    
    if Framework.CurrentFramework == 'QB' then
        local Player = Framework.Core.Functions.GetPlayer(xPlayer.source)
        if reward.type == "item" then
            local item = Player.Functions.GetItemByName(reward.item)
            if item then
                local freeWeight = Player.Functions.GetFreeSlots()
                local hasSpace = freeWeight >= reward.amount
                Log(hasSpace and 'SUCCESS' or 'WARNING', 'QB inventory check', {
                    freeSlots = freeWeight,
                    required = reward.amount,
                    hasSpace = hasSpace
                })
                return hasSpace
            end
        end
        return true
    elseif Framework.CurrentFramework == 'ESX' then
        if reward.type == "item" then
            local item = xPlayer.getInventoryItem(reward.item)
            if item then
                local canCarry = xPlayer.canCarryItem(reward.item, reward.amount)
                Log(canCarry and 'SUCCESS' or 'WARNING', 'ESX inventory check', {
                    item = reward.item,
                    amount = reward.amount,
                    canCarry = canCarry
                })
                return canCarry
            end
        end
        return true
    end
    return true
end

-- Get player's opened doors
RegisterNetEvent('fourtwenty_advent:getPlayerDoors')
AddEventHandler('fourtwenty_advent:getPlayerDoors', function()
    local source = source
    local xPlayer = Framework.GetPlayer(source)
    
    if not xPlayer then 
        Log('ERROR', 'Failed to get player doors - Invalid player', {source = source})
        return 
    end
    
    local identifier = Framework.GetIdentifier(xPlayer)
    Log('INFO', 'Getting player doors', {
        player = GetPlayerName(source),
        identifier = identifier
    })
    
    if not openedDoors[identifier] then
        openedDoors[identifier] = {}
        Log('INFO', 'Initialized new player data', {identifier = identifier})
    end
    
    -- Send only this player's doors
    TriggerClientEvent('fourtwenty_advent:receivePlayerDoors', source, openedDoors[identifier])
end)

-- Handle gift found event from client
RegisterNetEvent('fourtwenty_advent:giftFound')
AddEventHandler('fourtwenty_advent:giftFound', function(day, giftCoords)
    local source = source
    local xPlayer = Framework.GetPlayer(source)
    
    if not xPlayer then 
        Log('ERROR', 'Gift found event failed - Invalid player', {source = source, day = day})
        return 
    end
    
    local identifier = Framework.GetIdentifier(xPlayer)
    Log('INFO', 'Gift found event started', {
        player = GetPlayerName(source),
        identifier = identifier,
        day = day,
        coords = giftCoords
    })
    
    -- Check player distance from gift
    if not IsPlayerNearGift(source, vector3(giftCoords.x, giftCoords.y, giftCoords.z)) then
        Log('WARNING', 'Player too far from gift', {
            player = GetPlayerName(source),
            day = day
        })
        Framework.Notify(source, _U('too_far_from_gift'), 'error')
        return
    end
    
    if not openedDoors[identifier] then
        openedDoors[identifier] = {}
        Log('INFO', 'Initialized new player data during gift found', {identifier = identifier})
    end
    
    if tableContains(openedDoors[identifier], day) then
        Framework.Notify(source, _U('door_already_opened'), 'error')
        return
    end
    
    -- Process reward
    local reward = Config.Rewards[day]
    if reward then
        Log('INFO', 'Processing reward', {
            player = GetPlayerName(source),
            day = day,
            reward = reward
        })
        
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
                Log('WARNING', 'Insufficient inventory space for multi-reward', {
                    player = GetPlayerName(source),
                    day = day
                })
                Framework.Notify(source, _U('inventory_full'), 'error')
                return
            end
            
            -- Give all rewards
            for _, subReward in ipairs(reward.rewards) do
                local success = ProcessSingleReward(xPlayer, subReward)
                if success then
                    Log('SUCCESS', 'Multi-reward item given', {
                        player = GetPlayerName(source),
                        reward = subReward
                    })
                    TriggerClientEvent('fourtwenty_advent:receivedReward', source, subReward.notification)
                end
            end
            
            table.insert(openedDoors[identifier], day)
            SavePlayerData(identifier)
            TriggerClientEvent('fourtwenty_advent:receivedReward', source, reward.notification)
            
            -- Update this player's UI
            TriggerClientEvent('fourtwenty_advent:receivePlayerDoors', source, openedDoors[identifier])
            
            Log('SUCCESS', 'Multi-reward process completed', {
                player = GetPlayerName(source),
                day = day,
                rewards = reward.rewards
            })
        else
            -- Single reward
            if not HasInventorySpace(xPlayer, reward) then
                Log('WARNING', 'Insufficient inventory space for single reward', {
                    player = GetPlayerName(source),
                    day = day,
                    reward = reward
                })
                Framework.Notify(source, _U('inventory_full'), 'error')
                return
            end
            
            local success = ProcessSingleReward(xPlayer, reward)
            if success then
                table.insert(openedDoors[identifier], day)
                SavePlayerData(identifier)
                TriggerClientEvent('fourtwenty_advent:receivedReward', source, reward.notification)
                
                -- Update this player's UI
                TriggerClientEvent('fourtwenty_advent:receivePlayerDoors', source, openedDoors[identifier])
                
                Log('SUCCESS', 'Single reward process completed', {
                    player = GetPlayerName(source),
                    day = day,
                    reward = reward
                })
            end
        end
    end
end)

-- Process a single reward with error handling
function ProcessSingleReward(xPlayer, reward)
    if not xPlayer then 
        Log('ERROR', 'Process reward failed - Invalid player', {reward = reward})
        return false 
    end
    
    Log('INFO', 'Processing single reward', {
        player = GetPlayerName(xPlayer.source),
        reward = reward
    })
    
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
        Log('ERROR', 'Failed to process reward', {
            player = GetPlayerName(xPlayer.source),
            reward = reward,
            error = err
        })
        Framework.Notify(xPlayer.source, _U('error_processing_reward'), 'error')
        return false
    end
    
    Log('SUCCESS', 'Reward processed successfully', {
        player = GetPlayerName(xPlayer.source),
        reward = reward
    })
    return true
end

-- Admin command to reset calendar
RegisterCommand('adventreset', function(source, args, rawCommand)
    local xPlayer = Framework.GetPlayer(source)
    
    if Framework.IsAdmin(xPlayer) then
        Log('INFO', 'Admin reset command received', {
            admin = GetPlayerName(source),
            args = args
        })
        
        if args[1] == 'all' then
            -- Reset all players
            MySQL.Async.execute('DELETE FROM fourtwenty_advent WHERE year = @year', {
                ['@year'] = os.date('%Y')
            })
            openedDoors = {}
            Framework.Notify(source, _U('calendar_reset'), 'success')
            Log('SUCCESS', 'Calendar reset for all players', {
                admin = GetPlayerName(source)
            })
        else
            -- Reset specific player
            local targetIdentifier = args[1]
            MySQL.Async.execute('DELETE FROM fourtwenty_advent WHERE identifier = @identifier AND year = @year', {
                ['@identifier'] = targetIdentifier,
                ['@year'] = os.date('%Y')
            })
            openedDoors[targetIdentifier] = nil
            Framework.Notify(source, _U('calendar_reset_player'), 'success')
            Log('SUCCESS', 'Calendar reset for specific player', {
                admin = GetPlayerName(source),
                targetIdentifier = targetIdentifier
            })
        end
    else
        Log('WARNING', 'Unauthorized reset attempt', {
            player = GetPlayerName(source)
        })
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
