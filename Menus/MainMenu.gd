extends Control


# Start the game on press.
func _on_Start_pressed() -> void:
	Globals.game_dungeon_index = 0
	var _to_dungeon = get_tree().change_scene("res://Game.tscn")


# TODO: Enter editor mode.
func _on_Edit_pressed() -> void:
	pass  # Replace with function body.


# Exit the game.
func _on_Quit_pressed() -> void:
	get_tree().quit()
