extends Spatial

# Boss of the gym.
onready var _boss: Node = get_tree().get_nodes_in_group("Boss")[0]


# Runs on every physics tick.
# ? Should this run on just _process()?
func _physics_process(_delta: float) -> void:
	# Check if the boss is present in the scene.
	if not _boss:
		# Remove him
		$ProgressBar.queue_free()
		return
	$ProgressBar.value = _boss.health
