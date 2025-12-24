extends Node
class_name EnemySpawner
## EnemySpawner - Handles enemy spawning logic
## 
## Game logic for spawning enemies. Uses signals to notify of spawns.
## Does NOT handle rendering or physics - just the spawning logic.

## Emitted when an enemy should be spawned
signal enemy_spawn_requested(enemy_type: String, position: Vector2)

## Emitted when an enemy is killed
signal enemy_killed(enemy_type: String, souls_reward: float)

## Spawn rate (enemies per second)
@export var spawn_rate: float = 1.0

## Maximum active enemies
@export var max_enemies: int = 10

## Spawn area boundaries
@export var spawn_area_min: Vector2 = Vector2(100, 100)
@export var spawn_area_max: Vector2 = Vector2(1820, 980)

## Base souls values for different enemy types
@export var basic_enemy_souls: float = 1.0
@export var elite_enemy_souls: float = 5.0
@export var boss_enemy_souls: float = 20.0

var _active_enemy_count: int = 0
var _spawn_timer: float = 0.0

func _ready() -> void:
	# Connect to GameState
	enemy_killed.connect(_on_enemy_killed)

func _process(delta: float) -> void:
	_spawn_timer += delta
	
	var spawn_interval: float = 1.0 / spawn_rate
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		_try_spawn_enemy()

## Attempt to spawn an enemy
func _try_spawn_enemy() -> void:
	if _active_enemy_count >= max_enemies:
		return
	
	# Random spawn position (this is game logic, not rendering)
	var spawn_x: float = randf_range(spawn_area_min.x, spawn_area_max.x)
	var spawn_y: float = randf_range(spawn_area_min.y, spawn_area_max.y)
	var spawn_pos := Vector2(spawn_x, spawn_y)
	
	_active_enemy_count += 1
	enemy_spawn_requested.emit("basic", spawn_pos)

## Call this when an enemy is killed (from combat system)
func kill_enemy(enemy_type: String) -> void:
	_active_enemy_count = max(0, _active_enemy_count - 1)
	
	# Calculate souls reward based on enemy type and player stats
	var base_souls: float = _get_enemy_souls_value(enemy_type)
	var souls_reward: float = base_souls * GameState.get_stat("souls_multiplier")
	
	# Notify GameState
	GameState.enemy_killed(souls_reward)
	enemy_killed.emit(enemy_type, souls_reward)

## Get base souls value for enemy type
func _get_enemy_souls_value(enemy_type: String) -> float:
	match enemy_type:
		"basic":
			return basic_enemy_souls
		"elite":
			return elite_enemy_souls
		"boss":
			return boss_enemy_souls
		_:
			return basic_enemy_souls

func _on_enemy_killed(_enemy_type: String, _souls_reward: float) -> void:
	# Additional logic when enemies are killed
	pass
