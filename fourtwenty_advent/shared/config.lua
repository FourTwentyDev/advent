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

-- Gift Spawn Locations Per Door
Config.GiftLocations = {
    -- Day 1
    [1] = {
        vector3(228.8, -866.0, 30.5),    -- Location 1
        vector3(230.5, -870.2, 30.5),    -- Location 2
        vector3(225.3, -868.7, 30.5)     -- Location 3
    },
    -- Day 2
    [2] = {
        vector3(195.17, -934.8, 30.69),  -- Location 1
        vector3(198.45, -932.1, 30.69),  -- Location 2
        vector3(192.83, -937.2, 30.69)   -- Location 3
    },
    -- Day 3
    [3] = {
        vector3(1122.11, -644.44, 56.82), -- Location 1
        vector3(1125.33, -642.18, 56.82), -- Location 2
        vector3(1119.76, -646.91, 56.82)  -- Location 3
    },
    -- Day 4
    [4] = {
        vector3(-137.73, -246.53, 43.73), -- Location 1
        vector3(-134.92, -244.21, 43.73), -- Location 2
        vector3(-140.15, -248.84, 43.73)  -- Location 3
    },
    -- Day 5
    [5] = {
        vector3(-766.55, 465.97, 100.18), -- Location 1
        vector3(-763.82, 468.34, 100.18), -- Location 2
        vector3(-769.23, 463.55, 100.18)  -- Location 3
    },
    -- Day 6
    [6] = {
        vector3(808.72, -896.01, 25.25),  -- Location 1
        vector3(811.45, -893.67, 25.25),  -- Location 2
        vector3(806.14, -898.43, 25.25)   -- Location 3
    },
    -- Day 7
    [7] = {
        vector3(-916.04, -451.03, 39.61), -- Location 1
        vector3(-913.27, -448.76, 39.61), -- Location 2
        vector3(-918.82, -453.45, 39.61)  -- Location 3
    },
    -- Day 8
    [8] = {
        vector3(-1234.23, -1476.37, 4.37), -- Location 1
        vector3(-1231.56, -1473.92, 4.37), -- Location 2
        vector3(-1236.89, -1478.83, 4.37)  -- Location 3
    },
    -- Day 9
    [9] = {
        vector3(-1843.59, -1201.67, 13.02), -- Location 1
        vector3(-1840.87, -1199.23, 13.02), -- Location 2
        vector3(-1846.32, -1204.12, 13.02)  -- Location 3
    },
    -- Day 10
    [10] = {
        vector3(-1002.95, 354.62, 70.77),   -- Location 1
        vector3(-1000.23, 357.05, 70.77),   -- Location 2
        vector3(-1005.68, 352.18, 70.77)    -- Location 3
    },
    -- Day 11
    [11] = {
        vector3(235.12, -875.43, 30.5),     -- Location 1
        vector3(237.85, -872.98, 30.5),     -- Location 2
        vector3(232.40, -877.89, 30.5)      -- Location 3
    },
    -- Day 12
    [12] = {
        vector3(190.34, -940.21, 30.69),    -- Location 1
        vector3(193.07, -937.76, 30.69),    -- Location 2
        vector3(187.62, -942.67, 30.69)     -- Location 3
    },
    -- Day 13
    [13] = {
        vector3(1117.28, -649.87, 56.82),   -- Location 1
        vector3(1120.01, -647.42, 56.82),   -- Location 2
        vector3(1114.56, -652.33, 56.82)    -- Location 3
    },
    -- Day 14
    [14] = {
        vector3(-142.56, -251.86, 43.73),   -- Location 1
        vector3(-139.83, -249.41, 43.73),   -- Location 2
        vector3(-145.28, -254.32, 43.73)    -- Location 3
    },
    -- Day 15
    [15] = {
        vector3(-771.38, 461.64, 100.18),   -- Location 1
        vector3(-768.65, 464.09, 100.18),   -- Location 2
        vector3(-774.10, 459.18, 100.18)    -- Location 3
    },
    -- Day 16
    [16] = {
        vector3(803.89, -900.84, 25.25),    -- Location 1
        vector3(806.62, -898.39, 25.25),    -- Location 2
        vector3(801.17, -903.30, 25.25)     -- Location 3
    },
    -- Day 17
    [17] = {
        vector3(-920.87, -455.86, 39.61),   -- Location 1
        vector3(-918.14, -453.41, 39.61),   -- Location 2
        vector3(-923.59, -458.32, 39.61)    -- Location 3
    },
    -- Day 18
    [18] = {
        vector3(-1239.06, -1481.20, 4.37),  -- Location 1
        vector3(-1236.33, -1478.75, 4.37),  -- Location 2
        vector3(-1241.78, -1483.66, 4.37)   -- Location 3
    },
    -- Day 19
    [19] = {
        vector3(-1848.42, -1206.50, 13.02), -- Location 1
        vector3(-1845.69, -1204.05, 13.02), -- Location 2
        vector3(-1851.14, -1208.96, 13.02)  -- Location 3
    },
    -- Day 20
    [20] = {
        vector3(-1007.78, 349.79, 70.77),   -- Location 1
        vector3(-1005.05, 352.24, 70.77),   -- Location 2
        vector3(-1010.50, 347.33, 70.77)    -- Location 3
    },
    -- Day 21
    [21] = {
        vector3(240.95, -870.60, 30.5),     -- Location 1
        vector3(243.68, -868.15, 30.5),     -- Location 2
        vector3(238.23, -873.06, 30.5)      -- Location 3
    },
    -- Day 22
    [22] = {
        vector3(185.51, -945.04, 30.69),    -- Location 1
        vector3(188.24, -942.59, 30.69),    -- Location 2
        vector3(182.79, -947.50, 30.69)     -- Location 3
    },
    -- Day 23
    [23] = {
        vector3(1112.45, -654.70, 56.82),   -- Location 1
        vector3(1115.18, -652.25, 56.82),   -- Location 2
        vector3(1109.73, -657.16, 56.82)    -- Location 3
    },
    -- Day 24
    [24] = {
        vector3(-147.39, -256.69, 43.73),   -- Location 1
        vector3(-144.66, -254.24, 43.73),   -- Location 2
        vector3(-150.11, -259.15, 43.73)    -- Location 3
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
