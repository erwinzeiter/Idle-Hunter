# Idle Hunter

An idle/incremental game inspired by Idle Slayer, built with Godot 4.x and GDScript.

## Project Structure

The project follows a clean architecture pattern with clear separation of concerns:

```
Idle-Hunter/
├── scripts/
│   ├── autoload/
│   │   └── game_state.gd         # Single source of truth (autoload singleton)
│   ├── resources/
│   │   └── upgrade_data.gd        # Resource definitions (pure data)
│   ├── systems/
│   │   ├── upgrade_manager.gd     # Upgrade logic and management
│   │   └── enemy_spawner.gd       # Enemy spawning logic
│   ├── ui/
│   │   ├── currency_display.gd    # UI component for displaying currency
│   │   ├── stat_display.gd        # UI component for displaying stats
│   │   └── upgrade_button.gd      # UI component for upgrade buttons
│   └── main.gd                    # Main scene controller (wiring only)
├── scenes/
│   └── main.tscn                  # Main game scene
└── project.godot                  # Godot project configuration
```

## Architecture Principles

### 1. GameState as Single Source of Truth
- **GameState** (`scripts/autoload/game_state.gd`) is an autoload singleton that stores ALL game data
- Contains all currencies, player stats, upgrades, unlocked features, and statistics
- Other systems read from and write to GameState only
- Emits signals when data changes

### 2. UI Contains No Game Logic
- UI components only display data and forward user input
- All UI scripts connect to GameState signals and update display accordingly
- UI never modifies game state directly - always goes through GameState API
- Examples:
  - `CurrencyDisplay` - Displays currency, listens to `currency_changed` signal
  - `StatDisplay` - Displays player stats, listens to `stats_changed` signal
  - `UpgradeButton` - Displays upgrade info, calls `GameState.purchase_upgrade()`

### 3. Signal-Based Architecture
- Systems communicate via signals, not direct calls
- GameState emits signals when data changes:
  - `currency_changed(currency_type, new_amount)`
  - `upgrade_purchased(upgrade_id)`
  - `stats_changed(stat_name, new_value)`
  - `game_saved()` / `game_loaded()`
  - `passive_income_earned(currency_type, amount)`
- UI components listen to these signals and update automatically

### 4. Clean, Readable Code
- Extensive documentation with `##` doc comments
- Clear separation of concerns
- Typed variables where possible (GDScript 2.0 type hints)
- Descriptive function and variable names
- Organized with section headers in code

### 5. Scalable Systems
- Manager classes handle specific domains (UpgradeManager, EnemySpawner)
- Resource-based data definitions (UpgradeData)
- Easy to extend with new features without modifying core systems
- Modular architecture allows systems to be replaced or improved independently

## Core Systems

### GameState (Autoload Singleton)
The central data store and API for all game state:

**Currency Management:**
- `add_currency(type, amount)` - Add currency
- `spend_currency(type, amount)` - Spend currency (returns success)
- `get_currency(type)` - Get current amount
- `can_afford(type, amount)` - Check if player can afford

**Upgrade Management:**
- `purchase_upgrade(id, cost, currency_type)` - Purchase upgrade
- `get_upgrade_level(id)` - Get current upgrade level
- `has_upgrade(id)` - Check if upgrade is owned

**Player Stats:**
- `set_stat(name, value)` - Set stat value
- `get_stat(name)` - Get stat value
- `modify_stat(name, delta)` - Add to stat value

**Save/Load:**
- `save_game()` - Save to disk
- `load_game()` - Load from disk (automatic on startup)
- Auto-saves every 60 seconds
- Calculates offline progress on load

**Game Actions:**
- `enemy_killed(souls_earned)` - Call when enemy dies
- `apply_passive_income(delta)` - Apply passive income over time

### UpgradeManager
Manages upgrade definitions and categories:
- Initializes all available upgrades
- Provides queries for upgrades by ID or category
- Separates upgrade data from game state
- Easy to add new upgrades by extending `_initialize_upgrades()`

### EnemySpawner
Handles enemy spawning logic:
- Spawns enemies at configurable rate
- Manages active enemy count
- Emits signals for enemy spawn/kill events
- Calculates souls rewards based on enemy type and player stats

## UI Components

All UI components follow the same pattern:
1. Export parameters for configuration
2. Connect to GameState signals in `_ready()`
3. Update display when signals received
4. No game logic - only display and input forwarding

**CurrencyDisplay:**
- Displays a single currency amount
- Automatically formats large numbers (K, M, B)

**StatDisplay:**
- Displays a player stat
- Formats appropriately based on stat type (percentages, multipliers, etc.)

**UpgradeButton:**
- Displays upgrade info (name, cost, level)
- Enables/disables based on affordability
- Calls GameState.purchase_upgrade() when pressed
- Applies stat modifiers on successful purchase

## Adding New Features

### Adding a New Currency
1. Add to `GameState.currencies` dictionary
2. UI components will automatically work with it

### Adding a New Upgrade
1. Add entry in `UpgradeManager._initialize_upgrades()`
2. Create `UpgradeData` resource with all properties
3. UI will automatically display it

### Adding a New Stat
1. Add to `GameState.player_stats` dictionary
2. Add logic to use the stat in relevant systems
3. Add StatDisplay UI component to display it

### Adding a New System
1. Create new manager class extending Node
2. Add to Systems node in main scene
3. Connect to GameState signals as needed
4. Emit signals for other systems to react to

## Running the Game

1. Open project in Godot 4.x
2. Press F5 or click "Run Project"
3. Click "Test Kill Enemy" button to earn souls
4. Purchase upgrades to increase stats
5. Game auto-saves every 60 seconds

## Development Guidelines

- **Never** add game logic to UI scripts
- **Always** use GameState for data storage and retrieval
- **Always** use signals for cross-system communication
- **Always** document public functions with `##` doc comments
- **Always** use type hints for function parameters and return values
- **Test** each system independently before integration
- **Keep** functions small and focused on a single responsibility

## Platform Notes

- **Steam (Primary Target):** Full keyboard/mouse support
- **Mobile (Future):** Touch-friendly UI, scaling handled by Godot
- **Compatibility:** Godot 4.3+, GL Compatibility renderer for broad device support

## License

[Add your license here]
