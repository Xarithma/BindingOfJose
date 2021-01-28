extends MeshInstance

export var _text: Array = ["Paper Text Here!"]


func _physics_process(delta: float) -> void:
	var _ent_pos = Globals.player.global_transform.origin
	if ent_pos.distance_to(global_transform.origin):
		_read_paper()


func _read_paper() -> void:
	dialogue.set_bbcode()
