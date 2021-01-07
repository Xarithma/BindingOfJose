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

onready var player = get_tree().get_nodes_in_group("Player")[0]

var monsters: Array = []
var potions: Array = []

# Global scene loading for better performance.
func _ready() -> void:
	_load_scenes("res://Potions/", potions) # Load potions
	_load_scenes("res://Enemies/Scenes/", monsters) # Load monsters


func _process(_delta: float):
	for entity in get_tree().get_nodes_in_group("Player"):
		player = entity


func _load_scenes(_path: String, _arr: Array) -> void:
	var _dir: Directory = Directory.new()
	var _open := _dir.open(_path)
	var _list := _dir.list_dir_begin()
	
	while true:
		var _file: String = _dir.get_next()
		if _file == "":
			break
		elif !_file.begins_with("."):
			if ".tscn" in _file:
				_arr.append(load(_path + _file))
	_dir.list_dir_end()
