extends KinematicBody


var _acceleration: int = 6
var _current_speed: float = Globals.player_movement_speed

const _normal_acceleration: int = 8
const _mouse_sensitivity: float = 0.25

var _direction_vector: Vector3 = Vector3.ZERO
var _velocity_vector: Vector3 = Vector3.ZERO
var _movement_vector: Vector3 = Vector3.ZERO

onready var projectile = preload("res://Enemies/Utils/Projectile.tscn")

var _in_punch: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * _mouse_sensitivity))
		$Head.rotate_x(deg2rad(-event.relative.y * _mouse_sensitivity))
		$Head.rotation.x = clamp($Head.rotation.x, deg2rad(-89), deg2rad(89))

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event.is_action_pressed("ui_select"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event.is_action_pressed("shoot"):
		_in_punch = true
		$Head/Camera/Fist.play("punch")


func _physics_process(delta: float) -> void:
	_direction_vector = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		_direction_vector -= transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		_direction_vector += transform.basis.z
	if Input.is_action_pressed("move_left"):
		_direction_vector -= transform.basis.x
	elif Input.is_action_pressed("move_right"):
		_direction_vector += transform.basis.x

	_direction_vector = _direction_vector.normalized()
	_velocity_vector = _velocity_vector.linear_interpolate(
		_direction_vector * _current_speed, _acceleration * delta
	)
	_movement_vector.z = _velocity_vector.z
	_movement_vector.x = _velocity_vector.x

	var _move := move_and_slide(_movement_vector, Vector3.UP)


func _process(_delta: float) -> void:
	$Head/Camera/Debug.set_text("Health: %d" % Globals.player_health)
	$Head/HitBox/CollisionShape.disabled = !_in_punch


func damage(amount: int) -> void:
	Globals.player_health -= amount
	if Globals.player_health <= 0:
		var _death_camera = load("res://DeathCamera.tscn").instance()
		get_parent().add_child(_death_camera)
		_death_camera.global_transform.origin = global_transform.origin
		queue_free()


func slow_down() -> void:
	var _get_slow_speed: float = Globals.player_movement_speed / 2
	_current_speed = _get_slow_speed
	yield(get_tree().create_timer(3), "timeout")
	_current_speed = Globals.player_movement_speed


func _on_Fist_animation_finished() -> void:
	$Head/Camera/Fist.play("idle")
	_in_punch = false


func _on_HitBox_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		body.damage()
