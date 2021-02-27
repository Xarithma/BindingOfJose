extends Node

var player_movement_speed: float = 20
var player_attack_speed: float = 1
var player_attack_damage: float = 1
var player_health: float = 100
var player_max_health: float = player_health
var player_key_amount: float = 0

onready var reset_health: float = player_health
onready var reset_max_health: float = player_max_health
onready var reset_movement_speed: float = player_movement_speed
onready var reset_attack_speed: float = player_attack_speed
onready var reset_attack_damage: float = player_attack_damage
onready var reset_key_amount: float = player_key_amount

onready var player

# Preload scenes, so it gives a little better performance.
var monsters: Array = []
var potions: Array = []

# This determines the map loading logic.
var game_dungeon_index: int = 0
var game_dungeon_amount: int = 1
var game_map_to_load: String = "res://Game.tscn"

#  If I were to add more projectiles, I'll make a folder for it to load.
const projectile := preload("res://Enemies/Utils/Projectile.tscn")

# Load the boss portal to the scene.
const portal := preload("res://Dungeon/BossPortal.tscn")

# Since there are a lot of damage indicator calls, it's better to load once.
var hit_indicators: Array = []


# Global scene loading for better performance.
func _init() -> void:
	_load_scenes("res://Potions/Scenes/", potions)  # Load potions
	_load_scenes("res://Enemies/Scenes/", monsters)  # Load monsters
	_load_scenes("res://HUD/Scenes/", hit_indicators)  # Load dmg indicators


func _process(_delta: float):
	for entity in get_tree().get_nodes_in_group("Player"):
		player = entity
		entity.global_transform.origin.y = 3


func _load_scenes(_path: String, _arr: Array) -> void:
	var _dir: Directory = Directory.new()
	var _open := _dir.open(_path)
	var _list := _dir.list_dir_begin()

	while true:
		var _file: String = _dir.get_next()
		if _file == "":
			break
		elif ! _file.begins_with("."):
			if ".tscn" in _file:
				_arr.append(load(_path + _file))
	_dir.list_dir_end()

func set_next_level():
	game_dungeon_index += 1
	if game_dungeon_index >= game_dungeon_amount:
		game_map_to_load = "res://Ending.tscn"
