local Framework = {
    CurrentFramework = nil,
    Core = nil,
    a = "HI"
}


-- Framework Detection and Initialization
CreateThread(function()
    while true do
        if GetResourceState('es_extended') == 'started' then
            Framework.CurrentFramework = 'ESX'
            Framework.Core = exports['es_extended']:getSharedObject()
            break
        elseif GetResourceState('qb-core') == 'started' then
            Framework.CurrentFramework = 'QB'
            Framework.Core = exports['qb-core']:GetCoreObject()
            break
        end
        Wait(100)
    end
end)

-- Player Functions
function Framework.GetPlayer(source)
    if Framework.CurrentFramework == 'ESX' then
        return Framework.Core.GetPlayerFromId(source)
    elseif Framework.CurrentFramework == 'QB' then
        return Framework.Core.Functions.GetPlayer(source)
    end
end

function Framework.GetIdentifier(player)
    if Framework.CurrentFramework == 'ESX' then
        return player.identifier
    elseif Framework.CurrentFramework == 'QB' then
        return player.PlayerData.citizenid
    end
end

-- Money Functions
function Framework.AddMoney(player, type, amount)
    if Framework.CurrentFramework == 'ESX' then
        if type == 'cash' then
            player.addMoney(amount)
        elseif type == 'bank' then
            player.addAccountMoney('bank', amount)
        elseif type == 'black_money' then
            player.addAccountMoney('black_money', amount)
        end
    elseif Framework.CurrentFramework == 'QB' then
        if type == 'cash' then
            player.Functions.AddMoney('cash', amount)
        elseif type == 'bank' then
            player.Functions.AddMoney('bank', amount)
        elseif type == 'black_money' then
            player.Functions.AddMoney('black_money', amount)
        end
    end
end

-- Item Functions
function Framework.AddItem(player, item, amount)
    if Framework.CurrentFramework == 'ESX' then
        player.addInventoryItem(item, amount)
    elseif Framework.CurrentFramework == 'QB' then
        player.Functions.AddItem(item, amount)
    end
end

-- Weapon Functions
function Framework.AddWeapon(player, weapon, ammo)
    if Framework.CurrentFramework == 'ESX' then
        player.addWeapon(weapon, ammo)
    elseif Framework.CurrentFramework == 'QB' then
        player.Functions.AddItem(weapon, 1, false, {
            serie = tostring(Framework.Core.Shared.RandomInt(2) .. Framework.Core.Shared.RandomStr(3) .. Framework.Core.Shared.RandomInt(1) .. Framework.Core.Shared.RandomStr(2) .. Framework.Core.Shared.RandomInt(3) .. Framework.Core.Shared.RandomStr(4)),
            ammo = ammo
        })
    end
end

-- Notification Functions
function Framework.Notify(source, message, type, duration)
    duration = duration or 5000
    if Framework.CurrentFramework == 'ESX' then
        TriggerClientEvent('esx:showNotification', source, message)
    elseif Framework.CurrentFramework == 'QB' then
        TriggerClientEvent('QBCore:Notify', source, message, type, duration)
    end
end

-- Group Check Function
function Framework.IsAdmin(player)
    if Framework.CurrentFramework == 'ESX' then
        return player.getGroup() == 'admin'
    elseif Framework.CurrentFramework == 'QB' then
        return Framework.Core.Functions.HasPermission(player.PlayerData.source, 'admin')
    end
end

_G.Framework = Framework
return Framework