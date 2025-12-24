extends Node
## GameState - Single Source of Truth for all game data
## 
## This singleton manages all game state and acts as the central data store.
## UI and other systems should read from and react to changes in this state.
## All game logic resides here or in dedicated manager classes accessed through this state.

# ============================================================================
# SIGNALS - Used to notify UI and other systems of state changes
# ============================================================================

## Emitted when currency amount changes
signal currency_changed(currency_type: String, new_amount: float)

## Emitted when an upgrade is purchased
signal upgrade_purchased(upgrade_id: String)

## Emitted when player stats change (damage, speed, etc.)
signal stats_changed(stat_name: String, new_value: float)

## Emitted when the game is saved
signal game_saved()

## Emitted when the game is loaded
signal game_loaded()

## Emitted when passive income is calculated (per second)
signal passive_income_earned(currency_type: String, amount: float)

# ============================================================================
# STATE DATA - All game data stored here
# ============================================================================

## Currency amounts by type
var currencies: Dictionary = {
	"souls": 0.0,
	"coins": 0.0,
	"gems": 0.0
}

## Player statistics
var player_stats: Dictionary = {
	"damage": 1.0,
	"crit_chance": 0.05,
	"crit_multiplier": 2.0,
	"speed": 100.0,
	"souls_per_kill": 1.0,
	"souls_multiplier": 1.0
}

## Purchased upgrades (upgrade_id -> level)
var upgrades: Dictionary = {}

## Unlocked features/systems
var unlocked_features: Dictionary = {
	"upgrades": true,
	"prestige": false,
	"quests": false
}

## Game statistics
var statistics: Dictionary = {
	"total_souls_earned": 0.0,
	"total_enemies_killed": 0,
	"total_play_time": 0.0,
	"prestige_count": 0
}

## Current game session data
var session_data: Dictionary = {
	"enemies_killed_this_run": 0,
	"souls_earned_this_run": 0.0,
	"session_start_time": 0.0
}

# ============================================================================
# PRIVATE VARIABLES
# ============================================================================

var _save_path: String = "user://savegame.save"
var _auto_save_timer: float = 0.0
var _auto_save_interval: float = 60.0  # Auto-save every 60 seconds

# ============================================================================
# GODOT LIFECYCLE
# ============================================================================

func _ready() -> void:
	session_data.session_start_time = Time.get_unix_time_from_system()
	load_game()
	print("GameState initialized")

func _process(delta: float) -> void:
	# Update play time
	statistics.total_play_time += delta
	
	# Auto-save timer
	_auto_save_timer += delta
	if _auto_save_timer >= _auto_save_interval:
		_auto_save_timer = 0.0
		save_game()

# ============================================================================
# CURRENCY MANAGEMENT
# ============================================================================

## Add currency to the player's total
func add_currency(currency_type: String, amount: float) -> void:
	if not currencies.has(currency_type):
		push_error("Unknown currency type: " + currency_type)
		return
	
	if amount <= 0:
		return
	
	currencies[currency_type] += amount
	currency_changed.emit(currency_type, currencies[currency_type])
	
	# Update statistics
	if currency_type == "souls":
		statistics.total_souls_earned += amount
		session_data.souls_earned_this_run += amount

## Spend currency (returns true if successful)
func spend_currency(currency_type: String, amount: float) -> bool:
	if not currencies.has(currency_type):
		push_error("Unknown currency type: " + currency_type)
		return false
	
	if amount <= 0:
		return false
	
	if currencies[currency_type] < amount:
		return false
	
	currencies[currency_type] -= amount
	currency_changed.emit(currency_type, currencies[currency_type])
	return true

## Get current amount of currency
func get_currency(currency_type: String) -> float:
	if not currencies.has(currency_type):
		push_error("Unknown currency type: " + currency_type)
		return 0.0
	return currencies[currency_type]

## Check if player can afford a cost
func can_afford(currency_type: String, amount: float) -> bool:
	return get_currency(currency_type) >= amount

# ============================================================================
# UPGRADE MANAGEMENT
# ============================================================================

## Purchase an upgrade (returns true if successful)
func purchase_upgrade(upgrade_id: String, cost: float, currency_type: String = "souls") -> bool:
	if not can_afford(currency_type, cost):
		return false
	
	if spend_currency(currency_type, cost):
		# Increment upgrade level
		if not upgrades.has(upgrade_id):
			upgrades[upgrade_id] = 0
		upgrades[upgrade_id] += 1
		
		upgrade_purchased.emit(upgrade_id)
		return true
	
	return false

## Get current level of an upgrade
func get_upgrade_level(upgrade_id: String) -> int:
	return upgrades.get(upgrade_id, 0)

## Check if upgrade is owned (level > 0)
func has_upgrade(upgrade_id: String) -> bool:
	return get_upgrade_level(upgrade_id) > 0

# ============================================================================
# PLAYER STATS MANAGEMENT
# ============================================================================

## Set a player stat value
func set_stat(stat_name: String, value: float) -> void:
	if not player_stats.has(stat_name):
		push_error("Unknown stat: " + stat_name)
		return
	
	player_stats[stat_name] = value
	stats_changed.emit(stat_name, value)

## Get a player stat value
func get_stat(stat_name: String) -> float:
	return player_stats.get(stat_name, 0.0)

## Modify a stat by adding to its current value
func modify_stat(stat_name: String, delta: float) -> void:
	var current: float = get_stat(stat_name)
	set_stat(stat_name, current + delta)

## Calculate passive income per second for a currency
func get_passive_income_rate(currency_type: String) -> float:
	# This is a placeholder - implement based on owned upgrades
	var base_rate: float = 0.0
	
	# Example: Calculate based on upgrades
	if has_upgrade("passive_income_1"):
		base_rate += get_upgrade_level("passive_income_1") * 1.0
	
	return base_rate

# ============================================================================
# FEATURE UNLOCKING
# ============================================================================

## Unlock a game feature
func unlock_feature(feature_name: String) -> void:
	if not unlocked_features.has(feature_name):
		unlocked_features[feature_name] = false
	
	if not unlocked_features[feature_name]:
		unlocked_features[feature_name] = true
		print("Feature unlocked: ", feature_name)

## Check if a feature is unlocked
func is_feature_unlocked(feature_name: String) -> bool:
	return unlocked_features.get(feature_name, false)

# ============================================================================
# GAME ACTIONS
# ============================================================================

## Called when an enemy is killed
func enemy_killed(souls_earned: float = 0.0) -> void:
	statistics.total_enemies_killed += 1
	session_data.enemies_killed_this_run += 1
	
	if souls_earned <= 0:
		souls_earned = get_stat("souls_per_kill") * get_stat("souls_multiplier")
	
	add_currency("souls", souls_earned)

## Calculate and apply passive income
func apply_passive_income(delta: float) -> void:
	for currency_type in currencies.keys():
		var rate: float = get_passive_income_rate(currency_type)
		if rate > 0:
			var earned: float = rate * delta
			add_currency(currency_type, earned)
			passive_income_earned.emit(currency_type, earned)

# ============================================================================
# SAVE/LOAD SYSTEM
# ============================================================================

## Save the game state to disk
func save_game() -> void:
	var save_data: Dictionary = {
		"currencies": currencies,
		"player_stats": player_stats,
		"upgrades": upgrades,
		"unlocked_features": unlocked_features,
		"statistics": statistics,
		"save_time": Time.get_unix_time_from_system()
	}
	
	var save_file = FileAccess.open(_save_path, FileAccess.WRITE)
	if save_file == null:
		push_error("Failed to open save file for writing")
		return
	
	var json_string = JSON.stringify(save_data, "\t")
	save_file.store_line(json_string)
	save_file.close()
	
	game_saved.emit()
	print("Game saved successfully")

## Load the game state from disk
func load_game() -> void:
	if not FileAccess.file_exists(_save_path):
		print("No save file found, starting new game")
		return
	
	var save_file = FileAccess.open(_save_path, FileAccess.READ)
	if save_file == null:
		push_error("Failed to open save file for reading")
		return
	
	var json_string = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save file")
		return
	
	var save_data: Dictionary = json.data
	
	# Restore data
	if save_data.has("currencies"):
		currencies = save_data.currencies
	if save_data.has("player_stats"):
		player_stats = save_data.player_stats
	if save_data.has("upgrades"):
		upgrades = save_data.upgrades
	if save_data.has("unlocked_features"):
		unlocked_features = save_data.unlocked_features
	if save_data.has("statistics"):
		statistics = save_data.statistics
	
	# Calculate offline progress
	if save_data.has("save_time"):
		var offline_time: float = Time.get_unix_time_from_system() - save_data.save_time
		if offline_time > 0:
			_calculate_offline_progress(offline_time)
	
	game_loaded.emit()
	print("Game loaded successfully")

## Calculate offline progress (passive income while away)
func _calculate_offline_progress(offline_seconds: float) -> void:
	# Cap offline progress to prevent exploitation
	var max_offline_hours: float = 8.0
	var capped_seconds: float = min(offline_seconds, max_offline_hours * 3600.0)
	
	# Apply passive income for offline time
	apply_passive_income(capped_seconds)
	
	print("Offline progress calculated: ", capped_seconds, " seconds")

## Reset all game data (for testing or prestige)
func reset_game(keep_prestige_upgrades: bool = false) -> void:
	currencies = {
		"souls": 0.0,
		"coins": 0.0,
		"gems": 0.0
	}
	
	player_stats = {
		"damage": 1.0,
		"crit_chance": 0.05,
		"crit_multiplier": 2.0,
		"speed": 100.0,
		"souls_per_kill": 1.0,
		"souls_multiplier": 1.0
	}
	
	if not keep_prestige_upgrades:
		upgrades = {}
	
	session_data = {
		"enemies_killed_this_run": 0,
		"souls_earned_this_run": 0.0,
		"session_start_time": Time.get_unix_time_from_system()
	}
	
	save_game()
	print("Game reset")
