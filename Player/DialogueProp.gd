extends Label


var dialogue: Array = ["This is a placeholder message", "Please change!"]


func _ready() -> void:
	for letter in dialogue[0]:
		yield(get_tree().create_timer(0.07), "timeout")
		text += letter
