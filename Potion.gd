extends Spatial


enum BUFF_TYPE {
	ADD,
	MULTIPLY
}

export(BUFF_TYPE) var _type = BUFF_TYPE.ADD
export var _increase_speed: float = 5
export var _increase_attack_speed: float = 5
export var _increase_health: float = 5
export var _increase_max_health: float = 5
export var _increase_damage: float = 5


func _on_HitBox_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	match _type:
		BUFF_TYPE.ADD:
			Globals.player_movement_speed += _increase_speed
			Globals.player_attack_speed += _increase_attack_speed
			Globals.player_attack_damage += _increase_damage
			Globals.player_health += _increase_health
			Globals.player_max_health += _increase_max_health
		BUFF_TYPE.MULTIPLY:
			Globals.player_movement_speed *= _increase_speed
			Globals.player_attack_speed *= _increase_attack_speed
			Globals.player_attack_damage *= _increase_damage
			Globals.player_health *= _increase_health
			Globals.player_max_health *= _increase_max_health
	queue_free()
