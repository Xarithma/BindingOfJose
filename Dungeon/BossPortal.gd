extends Spatial


func _on_Hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Potion"):
		body.queue_free()

	if not body.is_in_group("Player"):
		return

	var _to_boss := get_tree().change_scene("res://Bosses/BossBattle.tscn")
