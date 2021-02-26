extends KinematicBody

# Damage the boss can deal in a single hit.
const _DAMAGE: int = 18

# Health of the boss.
var health: float = 50

# Controls which boss-phase is processed.
var _phase: int = 1

# ? Checks if the boss is tired. I don't think this is used anywhere?
var _stunned: bool = false

# For 2nd phase, switches between rush/tired.
var _in_rush: bool = false

# Shows whether the boss can deal damage.
var _can_damage: bool = true

# Since the map is cube, the boundary on every access is held by this int.
const _MOVEMENT_BORDER: int = 35

# The speed, which would be multiplied by direction * delta.
const _SPEED: int = 19

# A point which the boss would chase.
var _target: Vector3 = Vector3.ZERO


# Calls when node gets initialized.
func _ready() -> void:
	yield(get_tree().create_timer(3), "timeout")
	$AnimationPlayer.play("Jumping")


# Calls on every frame.
func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("Blub").size() == 0:
		_phase += 1
		set_process(false)


# Calls on every tick of the game. (60/s)
func _physics_process(_delta: float) -> void:
	
	# I mean, why should it run when she be stunned, right?
	if _stunned:
		return
	
	# Avoids bugs where the player is not present, but still calls.
	if not Globals.player:
		return

	# I hate writing global_transform.origin. I just did it again.
	global_transform.origin = _limit_boundaries()

	# Handles which phase to process, there are better ways pls no buli.
	match _phase:
		1:
			if not $AnimationPlayer.is_playing():
				
				# While "in-air" the boss cannot damage.
				_can_damage = false
				
				# This is because the boss pushes the player "in-air."
				$CollisionShape.disabled = false

				# Get the target position, while not jumping.
				_target = _get_velocity()
				
				return # So the process doesn't go further.
			
			# When the boss hit the ground...
			
			# The boss deals damage.
			_can_damage = true
			
			# The collision turns back on.
			$CollisionShape.disabled = true

		2:
			# Check if the boss is "tired."
			if not _in_rush:
				
				# Cannot damage while "tired."
				_can_damage = false
				
				return # So the process doesn't go further.
			
			# Constantly get the velocity while in rush.
			_target = _get_velocity()
			
			# Make sure that while the boss is rushing it can also damage.
			_can_damage = true

	# Movement call. I declare it so it not just "doesn't return anything."
	var _move: Vector3 = move_and_slide(_target, Vector3.UP)


# Doesn't allow the boss to leave the scene.
func _limit_boundaries() -> Vector3:
	
	# Temporary transform origin.
	var _origin: Vector3 = global_transform.origin
	
	# Check if the boss is passing a "border." If so push them back.
	if _origin.x > _MOVEMENT_BORDER:
		_origin.x -= 1
	elif _origin.x < -_MOVEMENT_BORDER:
		_origin.x += 1
	if _origin.z > _MOVEMENT_BORDER:
		_origin.z -= 1
	elif _origin.z < -_MOVEMENT_BORDER:
		_origin.z += 1
	
	# Return the new "pushed-back" origin.
	return _origin


# ? Might be changed later.
# This is a public funtion, and upon call the damage of the player is dealt.
func damage():
	health -= Globals.player_attack_damage
	if health <= 0:
		queue_free()


# Get the currect origin of the player.
func _get_player_pos() -> Vector3:
	# Target position = player position.
	var orig: Vector3 = Globals.player.global_transform.origin
	orig.y = 1  # Fix the height of the target.
	return orig


# Get the direction to the player origin.
func _get_direction_to_player() -> Vector3:
	return global_transform.origin.direction_to(_get_player_pos())


# Get the velocity for the boss.
func _get_velocity(delta: float = 1) -> Vector3:
	return _get_direction_to_player() * delta * _SPEED


# Enables the collision? I should remove the stuns.
func _reset_collision(_timer: int = 2):
	$AnimatedSprite3D/Area/CollisionShape.disabled = true
	$CollisionTimer.start(_timer)


# This is a fricking mess.
func _on_Area_body_entered(body: Node) -> void:
	
	# If the boss is already stunned, why bother?
	if _stunned:
		return

	# If the boss can't damage, than why?
	if not _can_damage:
		return
	
	# ! I want to remove this so badly...
	# Check if in the rush face the boss hit a wall.
	if _phase == 2 and body.is_in_group("Wall"):
		
		# Stun the mama.
		_stunned = true
		
		# Stun timer to get unstunned.
		$StunTimer.start(5)
		
		# Enable the collision again?
		_reset_collision(1)

	# Further than this, why bother if the body is not the player?
	if not body.is_in_group("Player"):
		return
	
	# Deal damage to the player.
	body.damage(_DAMAGE)
	
	# Slow the player down, 'cause y'know... blob?
	body.slow_down()
	
	# ... ? Maybe I shouldn't drink 3 cans of monster before... I code?
	_reset_collision()
	
	# Sets the "you've been damaged" indicator on the player.
	body.add_child(Globals.hit_indicators[0].instance())


# Jump if the timer runs out.
func _on_JumpTimer_timeout() -> void:
	
	# This only applies to phase 1.
	if _phase != 1:
		return
	
	# The
	$AnimationPlayer.play("Jumping")


# If the animation is finished (jump) this calls.
func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	
	# Stop the animation player (ofc)
	$AnimationPlayer.stop()
	
	# Restart the jump timer.
	$JumpTimer.start(1)


# Check if the stun cooldown expired.
func _on_StunTimer_timeout():
	
	# Turn off stuns.
	_stunned = false


func _on_CollisionTimer_timeout():
	$AnimatedSprite3D/Area/CollisionShape.disabled = false


func _on_RushTimer_timeout() -> void:
	_in_rush = not _in_rush

	if not _in_rush and _phase == 2:
		$AnimatedSprite3D.animation = "tired"
	elif _in_rush and _phase == 2:
		$AnimatedSprite3D.animation = "default"
