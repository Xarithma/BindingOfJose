extends Label

# This holds the texts which will be displayed to the player.
export var dialogue: Array = ["Hello, World!"]

# Value to set the letter play-speed.
export var letter_speed: float = 0.07

# Cooldown for the next dialogue, without keypress to show-up.
export var next_dialogue_cooldown: float = 2.5

# Index value to which part of the dialogue should be played.
var _dialogue_index: int = 0


func _input(event: InputEvent) -> void:
	# Skip the dialogue.
	if event.is_action_pressed("ui_cancel"):
		queue_free()


# Plays the dialogue set by the index.
func play_dialogue() -> void:
	for i in range(dialogue.size()):
		# Each letter from the current dialogue is added to the Label's `text.`
		for letter in dialogue[i]:
			yield(get_tree().create_timer(letter_speed), "timeout")
			text += letter
		yield(get_tree().create_timer(next_dialogue_cooldown), "timeout")
	queue_free()
