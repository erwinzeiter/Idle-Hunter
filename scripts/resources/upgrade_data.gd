extends Resource
class_name UpgradeData
## Resource defining an upgrade that can be purchased
## 
## This is pure data - no logic. GameState handles purchasing logic.

## Unique identifier for this upgrade
@export var id: String = ""

## Display name shown in UI
@export var display_name: String = ""

## Description shown in UI
@export_multiline var description: String = ""

## Base cost of the upgrade
@export var base_cost: float = 10.0

## Cost multiplier per level (exponential growth)
@export var cost_multiplier: float = 1.15

## Currency type used to purchase (souls, coins, gems)
@export var currency_type: String = "souls"

## Maximum level (0 = unlimited)
@export var max_level: int = 0

## Stat to modify when purchased
@export var stat_to_modify: String = ""

## Amount to add to stat per level
@export var stat_modifier_per_level: float = 0.0

## Icon texture path
@export var icon_path: String = ""

## Category for grouping in UI
@export var category: String = "general"

## Requires this feature to be unlocked
@export var required_feature: String = ""

## Calculate cost for a specific level
func get_cost_for_level(current_level: int) -> float:
	if current_level == 0:
		return base_cost
	return base_cost * pow(cost_multiplier, current_level)

## Check if upgrade can be leveled further
func can_level_up(current_level: int) -> bool:
	if max_level <= 0:
		return true
	return current_level < max_level
