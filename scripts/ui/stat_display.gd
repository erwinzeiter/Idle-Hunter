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
	text = format_string % FormatUtils.format_stat(stat_name, value)
