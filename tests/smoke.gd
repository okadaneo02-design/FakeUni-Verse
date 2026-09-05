extends Node3D
## Headless smoke test: hosts a session, builds the house, spawns the local
## player, then drives them through key locations on every floor.

const WorldScene := preload("res://scenes/World.tscn")

var _frames := 0
var _world: Node
var _player: Player
var _checkpoints := [
	Vector3(11.0, 0.0, 14.0),   # foyer
	Vector3(16.5, 0.0, 12.0),   # living
	Vector3(4.5, 0.0, 13.0),    # den
	Vector3(12.0, 0.0, 4.0),    # kitchen
	Vector3(10.3, 0.0, 9.5),    # hallway
	Vector3(11.8, 0.0, 9.0),    # on the stairs
	Vector3(10.5, 3.2, 12.0),   # up hallway
	Vector3(16.5, 3.2, 12.0),   # master
	Vector3(12.0, 3.2, 4.0),    # office
	Vector3(10.0, 3.2, 15.2),   # attic ladder foot
	Vector3(0.5, 0.0, 4.0),     # utility (basement stairs top)
	Vector3(0.5, -1.5, 2.5),    # on the basement stairs
	Vector3(6.0, -3.0, 8.0),    # bs_main
	Vector3(14.0, -3.0, 4.0),   # bs_boiler
	Vector3(16.0, -3.0, 11.0),  # bs_crawl
	Vector3(24.0, 0.0, 6.0),    # garage (beside the car)
	Vector3(11.0, 0.0, -2.0),   # backyard / patio
	Vector3(11.0, 0.0, 17.4),   # front porch
]
var _checkpoint := 0


func _ready() -> void:
	print("SMOKE: hosting...")
	if "short" in OS.get_cmdline_user_args():
		Globals.my_class = Globals.ClassType.SHORT
		print("SMOKE: class = SHORT")
	if not Net.host(9090):
		push_error("SMOKE: could not host")
		get_tree().quit(1)
		return
	_world = WorldScene.instantiate()
	add_child(_world)
	print("SMOKE: world ready, players=", Net.players)


func _process(_delta: float) -> void:
	_frames += 1
	if _frames % 180 == 0:
		print("SMOKE frame %d pos=%s vel=%s" % [_frames, _player.global_position if _player else "none", _player.velocity if _player else "none"])
	if _player == null and _world != null:
		_player = _world.get("_local_player")
	if _frames == 90:
		if _player == null:
			push_error("SMOKE: no local player spawned")
			get_tree().quit(1)
			return
		print("SMOKE: player spawned at ", _player.global_position, " class=", Globals.CLASS_NAMES[Globals.my_class])
		_player.global_position = _checkpoints[0]
	if _frames > 90 and _frames % 30 == 0 and _checkpoint < _checkpoints.size():
		_player.global_position = _checkpoints[_checkpoint]
		_player.velocity = Vector3.ZERO
		_checkpoint += 1
	if _frames == 720:
		Input.action_press("move_forward")
		Input.action_press("sprint")
	if _frames == 800:
		Input.action_press("jump")
	if _frames == 860:
		Input.action_release("jump")
	if _frames == 980:
		Input.action_release("move_forward")
		Input.action_release("sprint")
		print("SMOKE: movement run complete")
	if _frames >= 1100:
		print("SMOKE: PASS")
		get_tree().quit(0)