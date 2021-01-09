extends KinematicBody


onready var _target: Vector3 = Globals.player.global_transform.origin
const DAMAGE: int = 20
const MIN_DAMAGE: int = 3
const SPEED: int = 20


func _physics_process(delta: float) -> void:
	# Because I hate writing global_transform.origin everywhere.
	var _origin: Vector3 = global_transform.origin
	
	# Movement handling, I'm not making a function for the
	# same amount of lines and same optimization.
	_origin = _origin.move_toward(_target, delta * SPEED)
	global_transform.origin = _origin
	
	# Damage calculation.
	# The target is about 'where' the projectile should go.
	# Where player_origin is more about the current position.
	var _player_origin: Vector3 = Globals.player.global_transform.origin
	var _distance: float = _origin.distance_to(_player_origin)
	if _origin.distance_to(_target) < 1:
		var _damage = DAMAGE / _distance
		if _damage > MIN_DAMAGE:
			Globals.player.damage(DAMAGE / _distance)
		queue_free()
