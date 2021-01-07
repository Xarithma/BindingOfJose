extends AnimationPlayer


func _ready() -> void:
	get_animation("Floating").set_loop(true)
	play("Floating")
