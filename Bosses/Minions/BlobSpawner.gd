extends StaticBody


var health = 2
onready var _blub = preload("res://Enemies/Scenes/Blob.tscn")


func _physics_process(_delta: float) -> void:
	if $SpawnerTimer.time_left > 1:
		return
	
	if $AnimationPlayer.current_animation == "Spawning":
		return
	
	$AnimationPlayer.play("Spawning")


func damage() -> void:
	health -= Globals.player_attack_damage
	print("Damaged.")
	if health <= 0:
		queue_free()


func _on_SpawnerTimer_timeout() -> void:
	if get_tree().get_nodes_in_group("Enemy").size() >= 7:
		return
	
	$AnimationPlayer.play("Idle")
	var _blub_instance = _blub.instance()
	get_parent().add_child(_blub_instance)
	_blub_instance.global_transform.origin = global_transform.origin


func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	$AnimationPlayer.play("Idle")
