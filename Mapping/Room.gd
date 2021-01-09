extends MeshInstance


var _room_finished: bool = false
var _room_started: bool = false
const _RANGE: int = 15


func _ready() -> void:
	randomize()


func _process(_delta: float) -> void:
	if not _room_started:
		return
	
	if _room_finished:
		return
	
	if get_tree().get_nodes_in_group("Enemy").size() > 0:
		return
	
	$RoomLock/CollisionShape.disabled = true
	$RoomLock2/CollisionShape.disabled = true
	$RoomLock3/CollisionShape.disabled = true
	$RoomLock4/CollisionShape.disabled = true
	_room_finished = true
	
	var _potion = Globals.potions[randi() % Globals.potions.size()].instance()
	add_child(_potion)


func _on_Room_body_entered(body: Node) -> void:
	if _room_finished or _room_started:
		return
	
	if not body.is_in_group("Player"):
		return
	
	for _i in range(randi() % 4 + 1):
		var _random_monster = randi() % Globals.monsters.size()
		var _monster = Globals.monsters[_random_monster].instance()
		$MonsterHolder.add_child(_monster)
		var _origin = global_transform.origin
		var _rand_x_pos: float = _origin.x + rand_range(-_RANGE, _RANGE)
		var _rand_z_pos: float = _origin.z + rand_range(-_RANGE, _RANGE)
		_monster.transform.origin.x = _rand_x_pos
		_monster.transform.origin.z = _rand_z_pos
	
	$RoomLock/CollisionShape.disabled = false
	$RoomLock2/CollisionShape.disabled = false
	$RoomLock3/CollisionShape.disabled = false
	$RoomLock4/CollisionShape.disabled = false
	_room_started = true


func _on_Room_body_exited(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
