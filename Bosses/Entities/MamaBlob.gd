extends KinematicBody

const _DAMAGE: int = 18

var health: float = 50
var _phase: int = 1
var _stunned: bool = false
var _in_rush: bool = false
var _can_damage: bool = true

const _MOVEMENT_BORDER: int = 35
const _SPEED: int = 19

var _target: Vector3 = Vector3.ZERO


func _ready() -> void:
	yield(get_tree().create_timer(3), "timeout")
	$AnimationPlayer.play("Jumping")


func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("Blub").size() == 0:
		_phase += 1
		set_process(false)


func _physics_process(_delta: float) -> void:
	# I mean, why should it run when she be stunned, right?
	if _stunned:
		return

	if not Globals.player:
		return

	# I hate writing global_transform.origin. I just did it again.
	var _origin = global_transform.origin

	# I know there is a better way, pls no buli
	match _phase:
		1:
			if _origin.x > _MOVEMENT_BORDER:
				_origin.x -= 1
			elif _origin.x < -_MOVEMENT_BORDER:
				_origin.x += 1
			if _origin.z > _MOVEMENT_BORDER:
				_origin.z -= 1
			elif _origin.z < -_MOVEMENT_BORDER:
				_origin.z += 1

			if not $AnimationPlayer.is_playing():
				_can_damage = false
				$CollisionShape.disabled = false

				# Get the target position, while not jumping.
				_target = _get_direction_to_target()
				return

			_can_damage = true
			$CollisionShape.disabled = true

		2:
			if not _in_rush:
				_can_damage = false
				return

			# Get target position while rushing.
			_target = _get_direction_to_target()
			_can_damage = true


	var _move: Vector3 = move_and_slide(_get_velocity(), Vector3.UP)
	# _origin = _origin.move_toward(_target, _SPEED * delta)
	# global_transform.origin = _origin


func damage():
	health -= Globals.player_attack_damage
	if health <= 0:
		queue_free()


func _get_player_pos() -> Vector3:
	# Target position = player position.
	var orig: Vector3 = Globals.player.global_transform.origin
	orig.y = 1  # Fix the height of the target.
	return orig


func _get_direction_to_target() -> Vector3:
	return global_transform.origin.direction_to(_get_player_pos())


func _get_velocity(delta: float = 1) -> Vector3:
	return _get_direction_to_target() * delta


func _reset_collision(_timer: int = 2):
	$AnimatedSprite3D/Area/CollisionShape.disabled = true
	$CollisionTimer.start(_timer)


func _on_Area_body_entered(body: Node) -> void:
	if _stunned:
		return

	if not _can_damage:
		return

	if _phase == 2 and body.is_in_group("Wall"):
		_stunned = true
		print("Mama Blob is now stunned!")
		$StunTimer.start(5)
		_reset_collision(1)

	if not body.is_in_group("Player"):
		return
	body.damage(_DAMAGE)
	body.slow_down()

	_reset_collision()
	body.add_child(Globals.hit_indicators[0].instance())


func _on_JumpTimer_timeout() -> void:
	if _phase == 1:
		$AnimationPlayer.play("Jumping")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	$AnimationPlayer.stop()
	$JumpTimer.start(1)


func _on_StunTimer_timeout():
	_stunned = false


func _on_CollisionTimer_timeout():
	$AnimatedSprite3D/Area/CollisionShape.disabled = false


func _on_RushTimer_timeout() -> void:
	_in_rush = not _in_rush

	if not _in_rush and _phase == 2:
		$AnimatedSprite3D.animation = "tired"
	elif _in_rush and _phase == 2:
		$AnimatedSprite3D.animation = "default"
