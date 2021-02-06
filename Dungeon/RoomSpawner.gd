extends Position3D

# Top, bot, left, right.
export var _opening_direction: int = 0


func _ready() -> void:
	set_process(false)

	if get_tree().get_current_scene().rooms.has(global_transform.origin):
		return

	get_tree().get_current_scene().rooms.append(global_transform.origin)

	randomize()
	set_process(true)


func _process(_delta: float) -> void:
	# 
	var _rooms: Array

	match _opening_direction:
		1:  # Spawn top room
			_rooms = get_tree().get_current_scene().top_rooms
		2:  # Spawn bot room
			_rooms = get_tree().get_current_scene().bot_rooms
		3:  # Spawn left room
			_rooms = get_tree().get_current_scene().left_rooms
		4:  # Spawn right room
			_rooms = get_tree().get_current_scene().right_rooms

	# Choose a random index of the rooms array.
	var _random: int = randi() % _rooms.size()
	add_child(load(_rooms[_random]).instance())
	set_process(false)
