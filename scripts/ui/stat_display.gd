extends Label
## StatDisplay - Displays a player stat value
## 
## Pure UI component - reads from GameState and updates when stats change

## Stat name to display
@export var stat_name: String = "damage"

## Format string for display
@export var format_string: String = "Damage: %s"

func _ready() -> void:
	# Connect to GameState signals
	GameState.stats_changed.connect(_on_stat_changed)
	
	# Initial update
	_update_display()

func _on_stat_changed(changed_stat_name: String, _new_value: float) -> void:
	# Only update if this is our stat
	if changed_stat_name == stat_name:
		_update_display()

func _update_display() -> void:
	var value: float = GameState.get_stat(stat_name)
	text = format_string % _format_number(value)

## Format numbers appropriately
func _format_number(num: float) -> String:
	# For percentages (stats like crit_chance)
	if stat_name.contains("chance"):
		return "%.1f%%" % (num * 100.0)
	
	# For multipliers
	if stat_name.contains("multiplier"):
		return "%.2fx" % num
	
	# For regular numbers
	if num < 1000:
		return "%.1f" % num
	elif num < 1000000:
		return "%.2fK" % (num / 1000.0)
	else:
		return "%.2fM" % (num / 1000000.0)
