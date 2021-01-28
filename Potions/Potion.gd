extends Spatial

enum BUFF_TYPE { ADD, MULTIPLY }

export (BUFF_TYPE) var _type = BUFF_TYPE.ADD
export var _speed: float = 5
export var _attack_speed: float = 5
export var _health: float = 5
export var _max_health: float = 5
export var _damage: float = 5


func _ready() -> void:
	$AnimationPlayer.get_animation("Floating").set_loop(true)
	$AnimationPlayer.play("Floating")


func _on_HitBox_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	match _type:
		BUFF_TYPE.ADD:
			Globals.player_movement_speed += _speed
			Globals.player_attack_speed += _attack_speed
			Globals.player_attack_damage += _damage
			Globals.player_max_health += _max_health

			# I don't want the player to pick up a health-potion with no need.
			if Globals.player_health + _health > Globals.player_max_health:
				return

			Globals.player_health += _health

		BUFF_TYPE.MULTIPLY:
			Globals.player_movement_speed *= _speed
			Globals.player_attack_speed *= _attack_speed
			Globals.player_attack_damage *= _damage
			Globals.player_max_health *= _max_health

			# I don't want the player to pick up a health-potion with no need.
			if Globals.player_health + _health > Globals.player_max_health:
				return
			Globals.player_health *= _health

	var _dialogue = load("res://Converstaions/Potion.tscn").instance()
	get_parent().add_child(_dialogue)
	_dialogue.play_dialogue()
	queue_free()
