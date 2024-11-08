# FourTwenty Advent Calendar 🎄

A feature-rich and highly customizable advent calendar system for FiveM servers. Engage your players during the holiday season with daily rewards, interactive gift hunting, and a beautiful NUI interface.

## Features 🎁

### Interactive Gift Hunt System
- **Dynamic Gift Placement** 📍
  - Intelligent spawn system with ground detection
  - Multiple spawn zones across the map
  - Anti-glitch placement verification
  - Safe location algorithms

- **Engaging Search Mechanics** 🔍
  ```lua
  -- Example spawn zone configuration
  {
      center = vector3(228.8, -866.0, 30.5),
      radius = 40.0,
      minZ = 25.0,
      maxZ = 45.0
  }
  ```
  - Search area indicators
  - Proximity-based interactions
  - Visual and audio feedback
  - Anti-exploitation measures

### Advanced Calendar System
- **Daily Rewards System** 💝
  - Configurable rewards per day
  - Multiple reward types:
    - Items
    - Money
    - Bank transfers
    - Multi-rewards
  - Progress tracking
  - Anti-abuse mechanisms

### Modern NUI Interface
- **Responsive Design** 💻
  - Beautiful Christmas theme
  - Animated door interactions
  - Visual reward previews
  - Particle effects
  - Sound effects
  - Mobile-friendly layout

- **Interactive Elements** ✨
  - Door animations
  - Gift previews
  - Progress tracking
  - Visual notifications
  - Seasonal decorations

## Technical Details 🔧

### Database Structure
```sql
CREATE TABLE IF NOT EXISTS fourtwenty_advent (
    year INT NOT NULL,
    opened_doors LONGTEXT,
    PRIMARY KEY (year)
);
```

### Framework Support
- Full ESX integration
- QB-Core support
- Easily adaptable to other frameworks

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
```bash
mysql -u your_username -p your_database < advent.sql
```

3. Add to server.cfg
```lua
ensure fourtwenty_advent
```

4. Configure rewards in config.lua
```lua
-- Example reward configuration
Config.Rewards = {
    [1] = {
        type = "item",
        item = "food_sandwich",
        amount = 3,
        notification = "received 3x Holiday Sandwich!"
    }
}
```

## Configuration Options ⚙️

### Gift Properties
```lua
Config.GiftProps = {
    models = {
        'prop_box_tea01a',
        'prop_cs_box_clothes'
    },
    searchRadius = 100.0,
    timeToSearch = 5000,
    markerType = 1
}
```

### Spawn Zones
- Customizable spawn locations
- Safe zone definitions
- Height restrictions
- Area limitations

### Rewards
- Multiple reward types
- Customizable amounts
- Custom notifications
- Special multi-rewards

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
