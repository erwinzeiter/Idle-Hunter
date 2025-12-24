extends Button
## UpgradeButton - UI component for purchasing upgrades
## 
## Pure UI component - delegates all logic to GameState
## Only handles display and forwarding user input

## Reference to the upgrade data
@export var upgrade_data: UpgradeData

## Label to show upgrade name
@onready var name_label: Label = get_node_or_null("VBoxContainer/NameLabel")

## Label to show cost
@onready var cost_label: Label = get_node_or_null("VBoxContainer/CostLabel")

## Label to show current level
@onready var level_label: Label = get_node_or_null("VBoxContainer/LevelLabel")

func _ready() -> void:
	# Connect signals
	pressed.connect(_on_pressed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Initial update
	_update_display()

func _on_pressed() -> void:
	if upgrade_data == null:
		return
	
	var current_level: int = GameState.get_upgrade_level(upgrade_data.id)
	var cost: float = upgrade_data.get_cost_for_level(current_level)
	
	# Attempt purchase through GameState
	var success: bool = GameState.purchase_upgrade(
		upgrade_data.id,
		cost,
		upgrade_data.currency_type
	)
	
	if success and upgrade_data.stat_to_modify != "":
		# Apply stat modifier if defined
		GameState.modify_stat(
			upgrade_data.stat_to_modify,
			upgrade_data.stat_modifier_per_level
		)

func _on_currency_changed(_currency_type: String, _new_amount: float) -> void:
	_update_display()

func _on_upgrade_purchased(upgrade_id: String) -> void:
	if upgrade_data != null and upgrade_data.id == upgrade_id:
		_update_display()

func _update_display() -> void:
	if upgrade_data == null:
		return
	
	var current_level: int = GameState.get_upgrade_level(upgrade_data.id)
	var cost: float = upgrade_data.get_cost_for_level(current_level)
	var can_afford: bool = GameState.can_afford(upgrade_data.currency_type, cost)
	var can_level: bool = upgrade_data.can_level_up(current_level)
	
	# Update labels
	if name_label:
		name_label.text = upgrade_data.display_name
	
	if cost_label:
		cost_label.text = "Cost: " + _format_number(cost) + " " + upgrade_data.currency_type
	
	if level_label:
		if upgrade_data.max_level > 0:
			level_label.text = "Level: %d/%d" % [current_level, upgrade_data.max_level]
		else:
			level_label.text = "Level: %d" % current_level
	
	# Update button state
	disabled = not can_afford or not can_level
	text = upgrade_data.display_name if name_label == null else ""

## Format large numbers in a readable way
func _format_number(num: float) -> String:
	if num < 1000:
		return str(int(num))
	elif num < 1000000:
		return "%.2fK" % (num / 1000.0)
	elif num < 1000000000:
		return "%.2fM" % (num / 1000000.0)
	else:
		return "%.2fB" % (num / 1000000000.0)
