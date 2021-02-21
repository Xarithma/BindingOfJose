extends Spatial


func _on_Hitbox_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	# Loads the new map (Ending/Next Dungeon)
	var _to_next_map := get_tree().change_scene(Globals.game_map_to_load)
