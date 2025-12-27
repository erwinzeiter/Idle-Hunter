extends Node
class_name UpgradeManager
## UpgradeManager - Manages upgrade definitions and applications
## 
## Contains game logic for upgrades. Works with GameState for data storage.
## This separates upgrade logic from the state storage.

## Signal when upgrades are loaded
signal upgrades_loaded()

## All available upgrades
var available_upgrades: Array[UpgradeData] = []

func _ready() -> void:
	_initialize_upgrades()
	upgrades_loaded.emit()

## Initialize all upgrades
func _initialize_upgrades() -> void:
	available_upgrades.clear()
	
	# Damage upgrades
	var damage_upgrade := UpgradeData.new()
	damage_upgrade.id = "damage_1"
	damage_upgrade.display_name = "Sharp Blade"
	damage_upgrade.description = "Increases your damage"
	damage_upgrade.base_cost = 10.0
	damage_upgrade.cost_multiplier = 1.15
	damage_upgrade.stat_to_modify = "damage"
	damage_upgrade.stat_modifier_per_level = 1.0
	damage_upgrade.category = "combat"
	available_upgrades.append(damage_upgrade)
	
	# Speed upgrade
	var speed_upgrade := UpgradeData.new()
	speed_upgrade.id = "speed_1"
	speed_upgrade.display_name = "Swift Feet"
	speed_upgrade.description = "Increases your movement speed"
	speed_upgrade.base_cost = 15.0
	speed_upgrade.cost_multiplier = 1.2
	speed_upgrade.stat_to_modify = "speed"
	speed_upgrade.stat_modifier_per_level = 5.0
	speed_upgrade.category = "movement"
	available_upgrades.append(speed_upgrade)
	
	# Souls multiplier
	var souls_mult := UpgradeData.new()
	souls_mult.id = "souls_multiplier_1"
	souls_mult.display_name = "Soul Collector"
	souls_mult.description = "Increases souls gained from enemies"
	souls_mult.base_cost = 25.0
	souls_mult.cost_multiplier = 1.3
	souls_mult.stat_to_modify = "souls_multiplier"
	souls_mult.stat_modifier_per_level = 0.1
	souls_mult.category = "economy"
	available_upgrades.append(souls_mult)
	
	# Crit chance
	var crit_upgrade := UpgradeData.new()
	crit_upgrade.id = "crit_chance_1"
	crit_upgrade.display_name = "Precision Strike"
	crit_upgrade.description = "Increases critical hit chance"
	crit_upgrade.base_cost = 50.0
	crit_upgrade.cost_multiplier = 1.25
	crit_upgrade.stat_to_modify = "crit_chance"
	crit_upgrade.stat_modifier_per_level = 0.01
	crit_upgrade.max_level = 20
	crit_upgrade.category = "combat"
	available_upgrades.append(crit_upgrade)
	
	print("Loaded %d upgrades" % available_upgrades.size())

## Get upgrade by ID
func get_upgrade(upgrade_id: String) -> UpgradeData:
	for upgrade in available_upgrades:
		if upgrade.id == upgrade_id:
			return upgrade
	return null

## Get all upgrades in a category
func get_upgrades_by_category(category: String) -> Array[UpgradeData]:
	var result: Array[UpgradeData] = []
	for upgrade in available_upgrades:
		if upgrade.category == category:
			result.append(upgrade)
	return result

## Get all available categories
func get_categories() -> Array:
	var categories: Array = []
	for upgrade in available_upgrades:
		if not categories.has(upgrade.category):
			categories.append(upgrade.category)
	return categories
