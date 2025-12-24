# Godot 4 Idle Game - Code Examples

This document demonstrates how to use the architecture in various scenarios.

## Example 1: Adding a New Upgrade

```gdscript
# In UpgradeManager._initialize_upgrades()

# Add a new upgrade
var new_upgrade := UpgradeData.new()
new_upgrade.id = "health_regen"
new_upgrade.display_name = "Health Regeneration"
new_upgrade.description = "Regenerate health over time"
new_upgrade.base_cost = 100.0
new_upgrade.cost_multiplier = 1.5
new_upgrade.stat_to_modify = "health_regen"
new_upgrade.stat_modifier_per_level = 0.5
new_upgrade.category = "survival"
available_upgrades.append(new_upgrade)
```

## Example 2: Creating a Custom UI Component

```gdscript
extends Label
## Custom display component

@export var format_text: String = "Enemies Killed: %d"

func _ready() -> void:
    # Connect to relevant GameState signal
    GameState.game_loaded.connect(_update_display)
    _update_display()

func _update_display() -> void:
    # Read from GameState only
    var kills = GameState.statistics.total_enemies_killed
    text = format_text % kills
```

## Example 3: Creating a New Game System

```gdscript
extends Node
class_name QuestSystem
## Quest management system

signal quest_completed(quest_id: String)
signal quest_unlocked(quest_id: String)

var active_quests: Dictionary = {}

func _ready() -> void:
    # Listen to game events
    GameState.currency_changed.connect(_check_quest_progress)

func start_quest(quest_id: String) -> void:
    if quest_id in active_quests:
        return
    
    active_quests[quest_id] = {
        "progress": 0,
        "goal": 100
    }
    quest_unlocked.emit(quest_id)

func _check_quest_progress(_currency: String, _amount: float) -> void:
    for quest_id in active_quests:
        var quest = active_quests[quest_id]
        quest.progress += 1
        
        if quest.progress >= quest.goal:
            _complete_quest(quest_id)

func _complete_quest(quest_id: String) -> void:
    active_quests.erase(quest_id)
    GameState.add_currency("gems", 10.0)
    quest_completed.emit(quest_id)
```

## Example 4: Using GameState in Any Script

```gdscript
extends Node2D

func _ready() -> void:
    # Check if player can afford something
    if GameState.can_afford("souls", 50.0):
        print("Can afford!")
    
    # Listen to signals
    GameState.currency_changed.connect(_on_currency_changed)
    GameState.upgrade_purchased.connect(_on_upgrade_purchased)
    
    # Get current values
    var damage = GameState.get_stat("damage")
    var souls = GameState.get_currency("souls")
    
    print("Damage: ", damage, " Souls: ", souls)

func _on_currency_changed(currency_type: String, new_amount: float) -> void:
    print(currency_type, " changed to ", new_amount)

func _on_upgrade_purchased(upgrade_id: String) -> void:
    print("Purchased: ", upgrade_id)
    
    # Get the upgrade level
    var level = GameState.get_upgrade_level(upgrade_id)
    print("Now at level: ", level)
```

## Example 5: Adding a New Currency

```gdscript
# In game_state.gd, modify the currencies dictionary:

var currencies: Dictionary = {
    "souls": 0.0,
    "coins": 0.0,
    "gems": 0.0,
    "blood_essence": 0.0  # New currency
}

# Then use it anywhere:
GameState.add_currency("blood_essence", 5.0)
```

## Example 6: Responding to Multiple Signals

```gdscript
extends Control
## Complex UI panel responding to various events

func _ready() -> void:
    # Connect to multiple GameState signals
    GameState.currency_changed.connect(_on_any_currency_changed)
    GameState.stats_changed.connect(_on_any_stat_changed)
    GameState.upgrade_purchased.connect(_on_upgrade_purchased)
    GameState.game_saved.connect(_on_game_saved)

func _on_any_currency_changed(currency_type: String, new_amount: float) -> void:
    _refresh_ui()

func _on_any_stat_changed(stat_name: String, new_value: float) -> void:
    _refresh_ui()

func _on_upgrade_purchased(upgrade_id: String) -> void:
    _play_purchase_animation()
    _refresh_ui()

func _on_game_saved() -> void:
    _show_save_notification()

func _refresh_ui() -> void:
    # Update all displays
    pass
```

## Example 7: Creating a Passive Income System

```gdscript
extends Node
class_name PassiveIncomeSystem

@export var update_interval: float = 1.0

var _timer: float = 0.0

func _process(delta: float) -> void:
    _timer += delta
    
    if _timer >= update_interval:
        _timer = 0.0
        _apply_passive_income()

func _apply_passive_income() -> void:
    # Use GameState to apply passive income
    GameState.apply_passive_income(update_interval)
```

## Example 8: Testing Game Logic

```gdscript
# Test script (attach to a node and run scene)
extends Node

func _ready() -> void:
    _run_tests()

func _run_tests() -> void:
    print("=== Running Tests ===")
    
    # Test currency
    GameState.add_currency("souls", 100.0)
    assert(GameState.get_currency("souls") == 100.0, "Currency add failed")
    
    # Test spending
    var success = GameState.spend_currency("souls", 50.0)
    assert(success == true, "Currency spend failed")
    assert(GameState.get_currency("souls") == 50.0, "Currency amount wrong")
    
    # Test stats
    GameState.set_stat("damage", 10.0)
    assert(GameState.get_stat("damage") == 10.0, "Stat set failed")
    
    GameState.modify_stat("damage", 5.0)
    assert(GameState.get_stat("damage") == 15.0, "Stat modify failed")
    
    # Test upgrades
    var purchased = GameState.purchase_upgrade("test_upgrade", 10.0, "souls")
    assert(purchased == true, "Upgrade purchase failed")
    assert(GameState.get_upgrade_level("test_upgrade") == 1, "Upgrade level wrong")
    
    print("=== All Tests Passed ===")
```

## Best Practices

1. **Always read game state from GameState**
   ```gdscript
   var souls = GameState.get_currency("souls")  # Good
   var souls = some_ui_label.text  # Bad
   ```

2. **Always modify game state through GameState**
   ```gdscript
   GameState.add_currency("souls", 10)  # Good
   my_souls_variable += 10  # Bad
   ```

3. **Use signals for communication**
   ```gdscript
   GameState.currency_changed.connect(_on_currency_changed)  # Good
   _check_currency_every_frame()  # Bad (polling)
   ```

4. **Keep UI scripts simple**
   ```gdscript
   # Good: UI just displays
   func _update_display() -> void:
       text = "Souls: %d" % GameState.get_currency("souls")
   
   # Bad: UI contains game logic
   func _update_display() -> void:
       var souls = calculate_souls_with_bonuses()
       text = "Souls: %d" % souls
   ```

5. **Document public functions**
   ```gdscript
   ## Purchase an upgrade (returns true if successful)
   func purchase_upgrade(id: String, cost: float) -> bool:
       pass
   ```
