extends Spatial

# Boss of the gym.
onready var _boss: Node = get_tree().get_nodes_in_group("Boss")[0]


# Runs on every physics tick.
# ? Should this run on just _process()?
func _physics_process(_delta: float) -> void:
	if not _boss:
		return
	$ProgressBar.value = _boss.health
