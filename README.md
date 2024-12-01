# FourTwenty Advent Calendar 🎄

A feature-rich and highly customizable advent calendar system for FiveM servers. Engage your players during the holiday season with daily rewards, interactive gift hunting, and a beautiful NUI interface.

## Features 🎁

### Interactive Gift Hunt System
- **Dynamic Gift Placement** 📍
  - Multiple spawn locations per day (3 possible locations)
  - Safe location verification
  - Ground detection system
  - Anti-exploitation measures
  ```lua
  -- Example spawn location configuration
  [1] = {
      vector3(228.8, -866.0, 30.5),    -- Location 1
      vector3(230.5, -870.2, 30.5),    -- Location 2
      vector3(225.3, -868.7, 30.5)     -- Location 3
  }
  ```

### Advanced Calendar System
- **Daily Rewards System** 💝
  - Multiple reward types supported:
    - Items
    - Cash
    - Bank transfers
    - Multi-rewards (Day 24 special)
  ```lua
  -- Example reward configuration
  [24] = {
      type = "multi",
      rewards = {
          {
              type = "bank",
              amount = 25000
          },
          {
              type = "item",
              item = "heist_necklace_2",
              amount = 1
          }
      }
  }
  ```

### Modern NUI Interface
- **Responsive Design** 💻
  - 24 animated calendar doors
  - Custom door animations
  - Festive emojis for each day
  - Particle effects
  - Sound effects
  - Mobile-friendly layout

- **Interactive Elements** ✨
  - Animated door transitions
  - Gift preview system
  - Visual feedback
  - Sparkle effects
  - Custom sound effects

### Multilingual Support 🌍
- Built-in language system
- Currently supports:
  - English (en)
  - German (de)
- Easy to add new languages
```lua
Locale.Languages['en'] = {
    ['command_description'] = 'Open the Advent Calendar',
    ['gift_found'] = 'You found a gift!'
    -- Add more translations
}
```

## Technical Details 🔧

### Database Structure
```sql
CREATE TABLE IF NOT EXISTS fourtwenty_advent (
  identifier VARCHAR(50) NOT NULL,
  year INT NOT NULL,
  opened_doors JSON,
  PRIMARY KEY (identifier, year)
);
```

### Framework Support
- Full ESX integration
- QB-Core support
- Framework bridge for easy adaptation

## Dependencies 📦
- [es_extended](https://github.com/esx-framework/esx-legacy) or [qb-core](https://github.com/qbcore-framework/qb-core)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation 💿

1. Clone the repository
```bash
cd resources
git clone https://github.com/FourTwentyDev/advent
```

2. Import SQL schema
```sql
CREATE TABLE IF NOT EXISTS fourtwenty_advent (
    year INT NOT NULL,
    opened_doors LONGTEXT,
    PRIMARY KEY (year)
);
```

3. Add to server.cfg
```lua
ensure fourtwenty_advent
```

## Configuration Options ⚙️

### Gift Properties
```lua
Config.GiftProps = {
    models = {
        'prop_box_tea01a',
        'prop_cs_box_clothes',
        'prop_cs_box_step',
        'prop_box_ammo04a',
        'prop_paper_bag_01'
    },
    searchRadius = 100.0,
    timeToSearch = 5000,
    markerType = 1
}
```

### Sound Effects
```lua
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
```

### Discord Logging
```lua
Config.Logging = {
    enabled = true,
    webhook = "your-webhook-url"
}
```

## Performance 🚀
- Resource usage: 0.0ms idle
- Active usage: 0.01-0.02ms
- Optimized through:
  - Efficient spawn algorithms
  - Smart distance checks
  - Event batching
  - Resource state management

## Support & Links 💭
1. Join our [Discord](https://discord.gg/fourtwenty)
2. Visit [FourTwenty Development](https://fourtwenty.dev)
3. Create an issue on [GitHub](https://github.com/FourTwentyDev/advent)

## License 📄
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
Made with ❤️ by [FourTwenty Development](https://fourtwenty.dev)

### Latest Updates (v1.0.0)
- Initial release with full feature set
- Advanced gift placement system
- Interactive NUI calendar
- Multiple reward types
- Framework compatibility
- Full documentation
- Performance optimizations
