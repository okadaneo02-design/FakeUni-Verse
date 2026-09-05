extends Node3D
## Isolates the foyer drift: does the physics server push a bare capsule
## teleported to (11.0, 13.5)?

const WorldScene := preload("res://scenes/World.tscn")

var _player: Player
var _frames := 0
var _world: Node


func _ready() -> void:
	Net.host(9090)
	_world = WorldScene.instantiate()
	add_child(_world)


func _physics_process(_delta: float) -> void:
	_frames += 1
	if _player == null:
		_player = _world.get("_local_player")
		return
	if _frames == 10:
		_player.set_physics_process(false)
		_player.global_position = Vector3(11.0, 0.0, 13.5)
		_player.velocity = Vector3.ZERO
		print("TP with script disabled")
	if _frames >= 11 and _frames < 20:
		_player.move_and_slide()
		print("SLIDE pos=%s vel=%s colls=%d" % [_player.global_position, _player.velocity, _player.get_slide_collision_count()])
		for i in _player.get_slide_collision_count():
			var c := _player.get_slide_collision(i)
			print("   collider=%s normal=%s point=%s" % [c.get_collider().name if c.get_collider() else "?", c.get_normal(), c.get_position()])
	if _frames == 20:
		get_tree().quit(0)