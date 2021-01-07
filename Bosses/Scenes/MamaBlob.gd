extends KinematicBody


const DAMAGE: int = 24
const LIMIT: int = 35
var spawn_blub_amount: int = 0
var health: float = 50
var _phase: int = 1
var _stunned: bool = false
var _in_rush: bool = false

const _speed: int = 24

onready var _player


func _ready() -> void:
	yield(get_tree().create_timer(3), "timeout")
	$AnimationPlayer.play("Jumping")


func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("Blub").size() == 0:
		_phase = 2
		set_process(false)


func _physics_process(delta: float) -> void:
	# I mean, why should it run when she be stunned, right?
	if _stunned:
		return
	
	# I hate writing global_transform.origin. I just did it again.
	var _origin = global_transform.origin
	var _target: Vector3 = Globals.player.global_transform.origin
	_target.y = 1 # Fixing the height of the pathfinding.
	
	# I know there is a better way, pls no buli
	match _phase:
		1:
			# I know, this looks disgusting, but this is the best way
			# to keep Mama Blob in the ring. I'll have to figure out
			# something more sophisticated.
			if _origin.x > LIMIT:
				_origin.x -= 1
			elif _origin.x < -LIMIT:
				_origin.x += 1
			if _origin.z > LIMIT:
				_origin.z -= 1
			elif _origin.z < -LIMIT:
				_origin.z += 1

			if not $AnimationPlayer.is_playing():
				return
			_origin = _origin.move_toward(_target, delta * _speed)
			global_transform.origin = _origin
		2:
			if not Globals.player:
				return
			if _in_rush:
				var _direction: Vector3 = _origin.direction_to(_target)
				var _move := move_and_slide(_direction * _speed, Vector3.UP)


func damage():
	health -= Globals.player_attack_damage
	if health <= 0:
		queue_free()


func _reset_collision(_timer: int = 2):
	$AnimatedSprite3D/Area/CollisionShape.disabled = true
	$CollisionTimer.start(_timer)


func _get_rush_direction(_target):
	return global_transform.origin.direction_to(_target)


func _on_Area_body_entered(body: Node) -> void:
	if _stunned:
		return
	if _phase == 2 and body.is_in_group("Wall"):
		_stunned = true
		print("Mama Blob is now stunned!")
		$StunTimer.start(5)
		_reset_collision(1)
	if not body.is_in_group("Player"):
		return
	body.damage(DAMAGE)
	body.slow_down()
	_reset_collision()
	var _splash = load("res://BlobSplash.tscn").instance()
	body.add_child(_splash)


func _on_JumpTimer_timeout() -> void:
	if _phase == 1:
		$AnimationPlayer.play("Jumping")


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	$AnimationPlayer.stop()
	$JumpTimer.start(3)


func _on_StunTimer_timeout():
	_stunned = false
	print("Mama Blob is unstunned!")


func _on_CollisionTimer_timeout():
	$AnimatedSprite3D/Area/CollisionShape.disabled = false


func _on_RushTimer_timeout() -> void:
	_in_rush = not _in_rush
