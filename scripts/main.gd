extends Node2D
## Main - Entry point for the game
## 
## This script wires together UI and systems. No game logic here.
## All logic is in GameState or dedicated manager systems.

# Preload upgrade button scene
const UpgradeButtonScene = preload("res://scenes/upgrade_button.tscn")

@onready var upgrade_manager: UpgradeManager = $Systems/UpgradeManager
@onready var enemy_spawner: EnemySpawner = $Systems/EnemySpawner
@onready var upgrades_container: VBoxContainer = $UI/MarginContainer/VBoxContainer/UpgradesContainer
@onready var save_button: Button = $UI/MarginContainer/VBoxContainer/BottomControls/SaveButton
@onready var test_kill_button: Button = $UI/MarginContainer/VBoxContainer/BottomControls/TestKillButton

func _ready() -> void:
	# Connect UI buttons
	save_button.pressed.connect(_on_save_button_pressed)
	test_kill_button.pressed.connect(_on_test_kill_button_pressed)
	
	# Wait for upgrades to load, then populate UI
	upgrade_manager.upgrades_loaded.connect(_on_upgrades_loaded)

func _on_upgrades_loaded() -> void:
	_populate_upgrades_ui()

## Populate the upgrades UI with buttons
func _populate_upgrades_ui() -> void:
	# Clear existing children
	for child in upgrades_container.get_children():
		child.queue_free()
	
	# Create upgrade buttons for each upgrade
	for upgrade_data in upgrade_manager.available_upgrades:
		var button = UpgradeButtonScene.instantiate()
		button.upgrade_data = upgrade_data
		upgrades_container.add_child(button)

func _on_save_button_pressed() -> void:
	GameState.save_game()

func _on_test_kill_button_pressed() -> void:
	# Test button to simulate killing an enemy
	enemy_spawner.kill_enemy("basic")
