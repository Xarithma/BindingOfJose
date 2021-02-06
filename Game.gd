extends Node

var rooms: Array = [Vector3.ZERO]

var top_rooms: Array = []
var bot_rooms: Array = []
var left_rooms: Array = []
var right_rooms: Array = []


# Generates strings of the room paths.
func _ready() -> void:
	var _dir: Directory = Directory.new()
	var _path: String = "res://Dungeon/Rooms/"
	var _open := _dir.open(_path)
	var _list := _dir.list_dir_begin()

	while true:
		var _file: String = _dir.get_next()
		if _file == "":
			break
		elif not _file.begins_with("."):
			if "F" in _file:
				top_rooms.append(_path + _file)
			if "B" in _file:
				bot_rooms.append(_path + _file)
			if "L" in _file:
				left_rooms.append(_path + _file)
			if "R" in _file:
				right_rooms.append(_path + _file)
	_dir.list_dir_end()


# Fade in to the scene.
func _physics_process(delta: float) -> void:
	$FadeIn.color.a = lerp($FadeIn.color.a, 0, delta)
	if $FadeIn.color.a < 0.01:
		$FadeIn.queue_free()
		set_physics_process(false)


# Spawn the portal after the generation timeout.
func _on_PortalTimer_timeout() -> void:
	# Instance of the boss portal.
	var _portal_instance = Globals.portal.instance()

	# Add the portal scene to the game scene.
	add_child(_portal_instance)

	# Set the portal's position to the last room.
	_portal_instance.global_transform.origin = rooms.back()

	# ! Remove this on release.
	print("Portal spawned at " + str(_portal_instance.global_transform.origin))
