extends Spatial

# Boss of the gym.
onready var _boss: Node = get_tree().get_nodes_in_group("Boss")[0]


# Runs on every physics tick.
# ? Should this run on just _process()?
func _physics_process(_delta: float) -> void:
	for boss in get_tree().get_nodes_in_group("Boss"):
		# Update the boss's health.
		$UserInterface/ProgressBar.value = boss.health

		return  # Don't let the code go further.

	# The health bar can be deleted.
	$UserInterface/ProgressBar.queue_free()
