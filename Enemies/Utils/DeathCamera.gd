extends Camera


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		Globals.player_health = Globals.reset_health
		Globals.player_max_health = Globals.reset_max_health
		Globals.player_movement_speed = Globals.reset_movement_speed
		Globals.player_attack_damage = Globals.reset_attack_damage
		Globals.player_attack_speed = Globals.reset_attack_speed
		Globals.player_key_amount = Globals.reset_key_amount
		var _reset := get_tree().change_scene("res://Game.tscn")
