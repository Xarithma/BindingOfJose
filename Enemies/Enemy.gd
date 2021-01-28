extends KinematicBody

# ! WARNING
# This is probably the biggest junk code I have ever commited.
# If you feel like throwing up, please, just take this script
# as granted. Because there is no way, I'm gonna explain something
# I made several days ago, on a coffein overload, and just expect
# people to understand even mumbling about this.

enum ENEMY_TYPE { NONE, BLOB, TURRET }

export (ENEMY_TYPE) var _type = ENEMY_TYPE.BLOB
export var _health: float = 5
export var _height: float = 3
export var _attack_speed: float = 0.5

# Path finding
var _path: Array = []
var _path_node: int = 0

export var _speed: int = 7

# Knockback
var _in_knockback: bool = false
var _knockback_power: int = _speed * 100
const KNOCKBACK_TIMER: float = 0.5

# Rush
var _in_rush: bool = false
const RUSH_TIMER = 2

# Retreat
var _retreat: bool = false

# Damage
export var _damage: int = 19


func _physics_process(delta: float) -> void:
	if not Globals.player:
		return

	global_transform.origin.y = _height

	var _target: Vector3 = Globals.player.global_transform.origin
	_target.y = 10

	if _in_knockback:
		var _move := _do_knockback(_target, delta)
	else:
		match _type:
			ENEMY_TYPE.BLOB:
				if _in_rush and not $Area/CollisionShape.disabled:
					_handle_movement(_target, delta * _speed * 5)
					return
			ENEMY_TYPE.TURRET:
				if _retreat:
					var _move := _do_retreat(_target, delta)
				return
		if not $Area/CollisionShape.disabled:
			_handle_movement(_target, delta * _speed)
		var _collide = move_and_collide(Vector3.ZERO)


func _do_knockback(_target: Vector3, delta: float) -> Vector3:
	var _direction: Vector3 = -global_transform.origin.direction_to(_target)
	return move_and_slide(_direction * delta * 1000, Vector3.UP)


func _do_retreat(_target: Vector3, delta: float) -> Vector3:
	var _direction: Vector3 = -global_transform.origin.direction_to(_target)
	return move_and_slide(_direction * delta * 500, Vector3.UP)


func _handle_movement(target: Vector3, vel: float) -> void:
	global_transform.origin = global_transform.origin.move_toward(target, vel)


func damage() -> void:
	_health -= Globals.player_attack_damage
	_in_knockback = true
	$KnockbackTimer.start(KNOCKBACK_TIMER)
	if _health <= 0:
		queue_free()


func _on_AttackCooldown_timeout() -> void:
	if _type == ENEMY_TYPE.TURRET:
		var _projectile_instance = Globals.projectile.instance()
		get_parent().add_child(_projectile_instance)
		var _origin: Vector3 = global_transform.origin
		_projectile_instance.global_transform.origin = _origin
		return

	$Area/CollisionShape.disabled = false


func _on_KnockbackTimer_timeout() -> void:
	_in_knockback = false


func _on_BlobTimer_timeout() -> void:
	if _in_rush:
		_in_rush = false
	elif not _in_rush:
		_in_rush = true


func _spawn_hit_indicator():
	var _indicator

	if _type == ENEMY_TYPE.BLOB:
		_indicator = Globals.hit_indicators[0].instance()
	else:
		_indicator = Globals.hit_indicators[1].instance()
	Globals.player.add_child(_indicator)


func _on_Area_body_entered(body: Node) -> void:
	if _type == ENEMY_TYPE.TURRET:
		return

	if not body.is_in_group("Player"):
		return

	if $Area/CollisionShape.disabled:
		return

	$Area/CollisionShape.disabled = true
	$AttackCooldown.start(_attack_speed)

	body.damage(_damage)
	_spawn_hit_indicator()


func _set_retreat(_should_retreat: bool, body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	if _type != ENEMY_TYPE.TURRET:
		return
	_retreat = _should_retreat


func _on_DistanceCheck_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	_set_retreat(true, body)


func _on_DistanceCheck_body_exited(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	_set_retreat(false, body)
