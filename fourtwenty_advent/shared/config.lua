Config = {}

-- UI Configuration
Config.UI = {
    command = 'advent',
    InventoryLink = "nui://inventory/web/dist/assets/items/%s.png"
}

-- Gift Properties
Config.GiftProps = {
    -- Available gift prop models
    models = {
        'prop_box_tea01a',      -- Small gift box
        'prop_cs_box_clothes',  -- Wrapped gift box
        'prop_cs_box_step',     -- Small decorative box
        'prop_box_ammo04a',     -- Compact gift box
        'prop_paper_bag_01',    -- Gift bag
    },
    searchRadius = 100.0,       -- Radius for gift search area
    timeToSearch = 5000,        -- Time in ms to search gift
    markerType = 1,            -- Type of marker to display
    markerColor = {            -- Marker color (RGBA)
        r = 255,
        g = 0,
        b = 0,
        a = 100
    },
    blipSprite = 9,           -- Search area blip sprite
    giftBlipSprite = 568      -- Gift location blip sprite
}

-- Spawn Zones Configuration
Config.SpawnZones = {
    -- Vinewood Boulevard (Shopping District)
    {
        center = vector3(228.8, -866.0, 30.5),
        radius = 40.0,
        minZ = 25.0,
        maxZ = 45.0
    },
    -- Legion Square (Central Plaza)
    {
        center = vector3(195.17, -934.8, 30.69),
        radius = 50.0,
        minZ = 25.0,
        maxZ = 45.0
    },
    -- Mirror Park (Residential Area with Park)
    {
        center = vector3(1122.11, -644.44, 56.82),
        radius = 45.0,
        minZ = 51.0,
        maxZ = 71.0
    },
    -- Vespucci Beach Promenade
    {
        center = vector3(-1234.23, -1476.37, 4.37),
        radius = 55.0,
        minZ = 1.0,
        maxZ = 15.0
    },
    -- Rockford Plaza (Shopping Center Area)
    {
        center = vector3(-137.73, -246.53, 43.73),
        radius = 45.0,
        minZ = 38.0,
        maxZ = 58.0
    },
    -- Vinewood Hills (Luxury Viewpoints)
    {
        center = vector3(-766.55, 465.97, 100.18),
        radius = 60.0,
        minZ = 95.0,
        maxZ = 115.0
    },
    -- Del Perro Pier (Amusement Area)
    {
        center = vector3(-1843.59, -1201.67, 13.02),
        radius = 50.0,
        minZ = 8.0,
        maxZ = 28.0
    },
    -- Galileo Park (Quiet Park Area)
    {
        center = vector3(-1002.95, 354.62, 70.77),
        radius = 45.0,
        minZ = 65.0,
        maxZ = 85.0
    },
    -- La Mesa (Industrial District)
    {
        center = vector3(808.72, -896.01, 25.25),
        radius = 40.0,
        minZ = 20.0,
        maxZ = 40.0
    },
    -- Weazel Plaza (Office District)
    {
        center = vector3(-916.04, -451.03, 39.61),
        radius = 45.0,
        minZ = 34.0,
        maxZ = 54.0
    }
}

-- Sound Effect Configuration
Config.Sounds = {
    doorOpen = {
        name = "NAV_UP_DOWN",
        dict = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    },
    giftFound = {
        name = "CHALLENGE_UNLOCKED",
        dict = "HUD_AWARDS"
    }
}

-- Daily Rewards Configuration
Config.Rewards = {
    -- Day 1
    [1] = {
        type = "item",
        item = "food_sandwich",
        amount = 3,
        notification = "received 3x Holiday Sandwich!"
    },
    -- Day 2
    [2] = {
        type = "money",
        amount = 2500,
        notification = "received $2,500 Holiday Bonus!"
    },
    -- Day 3
    [3] = {
        type = "item",
        item = "alc_wine",
        amount = 1,
        notification = "received a bottle of Holiday Wine!"
    },
    -- Day 4
    [4] = {
        type = "item",
        item = "radio",
        amount = 1,
        notification = "received a Festive Radio!"
    },
    -- Day 5
    [5] = {
        type = "item",
        item = "heist_watch_1",
        amount = 1,
        notification = "received a Festive Watch!"
    },
    -- Day 6
    [6] = {
        type = "bank",
        amount = 5000,
        notification = "received $5,000 Holiday Bank Bonus!"
    },
    -- Day 7
    [7] = {
        type = "item",
        item = "food_donut",
        amount = 5,
        notification = "received 5x Holiday Donuts!"
    },
    -- Day 8
    [8] = {
        type = "item",
        item = "heal_medikit",
        amount = 2,
        notification = "received 2x Winter Emergency Kit!"
    },
    -- Day 9
    [9] = {
        type = "item",
        item = "fun_scratchcard",
        amount = 3,
        notification = "received 3x Holiday Scratch Cards!"
    },
    -- Day 10
    [10] = {
        type = "money",
        amount = 7500,
        notification = "received $7,500 Generous Holiday Bonus!"
    },
    -- Day 11
    [11] = {
        type = "item",
        item = "heist_necklace_1",
        amount = 1,
        notification = "received a Festive Necklace!"
    },
    -- Day 12
    [12] = {
        type = "item",
        item = "food_burger",
        amount = 3,
        notification = "received 3x Holiday Burger!"
    },
    -- Day 13
    [13] = {
        type = "bank",
        amount = 10000,
        notification = "received $10,000 Holiday Deluxe Bonus!"
    },
    -- Day 14
    [14] = {
        type = "item",
        item = "drink_orangejuice",
        amount = 5,
        notification = "received 5x Winter Orange Juice!"
    },
    -- Day 15
    [15] = {
        type = "item",
        item = "phone",
        amount = 1,
        notification = "received a Holiday Smartphone!"
    },
    -- Day 16
    [16] = {
        type = "item",
        item = "veh_repairkit",
        amount = 2,
        notification = "received 2x Winter Repair Kit!"
    },
    -- Day 17
    [17] = {
        type = "item",
        item = "heist_perfume",
        amount = 1,
        notification = "received Holiday Perfume!"
    },
    -- Day 18
    [18] = {
        type = "money",
        amount = 15000,
        notification = "received $15,000 Grand Holiday Bonus!"
    },
    -- Day 19
    [19] = {
        type = "item",
        item = "casino_luckypotion",
        amount = 1,
        notification = "received a Holiday Lucky Potion!"
    },
    -- Day 20
    [20] = {
        type = "item",
        item = "heal_vest",
        amount = 1,
        notification = "received a Festive Armor Vest!"
    },
    -- Day 21
    [21] = {
        type = "bank",
        amount = 20000,
        notification = "received $20,000 Holiday Premium Bonus!"
    },
    -- Day 22
    [22] = {
        type = "item",
        item = "alc_whisky",
        amount = 1,
        notification = "received Holiday Whiskey!"
    },
    -- Day 23
    [23] = {
        type = "item",
        item = "heist_watch_2",
        amount = 1,
        notification = "received a Luxury Holiday Watch!"
    },
    -- Day 24 (Christmas Eve Special)
    [24] = {
        type = "multi",
        rewards = {
            {
                type = "bank",
                amount = 25000,
                notification = "received $25,000 Holiday Finale Bonus!"
            },
            {
                type = "item",
                item = "heist_necklace_2",
                amount = 1,
                notification = "received a Special Holiday Necklace!"
            },
            {
                type = "item",
                item = "heal_vest",
                amount = 1,
                notification = "received a Holiday Armor Vest!"
            }
        },
        notification = "received the Grand Holiday Finale Package!"
    }
}

-- Discord Logging Configuration
Config.Logging = {
    enabled = true,
    webhook = ""  -- Discord webhook URL
}

return Config