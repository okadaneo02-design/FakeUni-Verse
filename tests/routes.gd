extends Node3D
## Route test: drives the player through real doorways with input.
## TALL must crouch through the 2.1m doors; SHORT walks through standing.
## Also verifies the lintel block: TALL standing is stopped by a doorway.

const WorldScene := preload("res://scenes/World.tscn")

var _frames := 0
var _world: Node
var _player: Player
var _phase := 0
var _phase_start := 0
var _results := []
var _trace := 0
var _is_short := false


func _ready() -> void:
	_is_short = "short" in OS.get_cmdline_user_args()
	if _is_short:
		Globals.my_class = Globals.ClassType.SHORT
	print("ROUTE: ready class=", Globals.CLASS_NAMES[Globals.my_class])
	Net.host(9090)
	_world = WorldScene.instantiate()
	add_child(_world)


func _physics_process(_delta: float) -> void:
	_frames += 1
	if _player == null:
		_player = _world.get("_local_player") if _world else null
		return
	match _phase:
		0:
			# through foyer -> hallway door (door x10.525..11.475, lintel 2.1)
			_begin(Vector3(10.0, 0.0, 13.5), 0.0)
			if not _is_short:
				Input.action_press("crouch")
			_phase += 1
		1:
			if _frames - _phase_start < 20 and _frames % 3 == 0:
				print("DRIFT frame=%d pos=%s vel=%s" % [_frames - _phase_start, _player.global_position, _player.velocity])
			_check_done(3.2, "foyer->hallway", func() -> bool: return _player.global_position.z < 12.1)
		2:
			# hallway -> dining (door z8.025..8.975)
			_begin(Vector3(9.0, 0.0, 8.5), PI / 2.0)
			_phase += 1
		3:
			_check_done(2.4, "hallway->dining", func() -> bool: return _player.global_position.x < 8.3)
		4:
			# kitchen back door: STANDING test (lintel at 2.1)
			Input.action_release("crouch")
			_begin(Vector3(11.5, 0.0, 1.2), 0.0)
			_phase += 1
		5:
			if _is_short:
				# short walks straight out standing
				_check_done(2.4, "short-standing-passes", func() -> bool: return _player.global_position.z < 0.2)
			else:
				# tall standing: blocked by the lintel
				_check_done(2.0, "tall-standing-blocked", func() -> bool: return _player.global_position.z > 0.5)
		6:
			# now crouch (tall) / stay (short) and go out
			_begin(Vector3(11.5, 0.0, 1.2), 0.0)
			if not _is_short:
				Input.action_press("crouch")
			_phase += 1
		7:
			_check_done(3.0, "out-the-back-door", func() -> bool: return _player.global_position.z < 0.2)
		8:
			Input.action_release("crouch")
			Input.action_release("move_forward")
			_show_results()
			get_tree().quit(0)


func _begin(pos: Vector3, yaw: float) -> void:
	_player.global_position = pos
	_player.global_rotation = Vector3(0, yaw, 0)
	_player.velocity = Vector3.ZERO
	Input.action_press("move_forward")
	_phase_start = _frames
	_trace = 0


func _check_done(seconds: float, label: String, cond: Callable) -> void:
	if _frames - _phase_start > int(seconds * 60.0):
		Input.action_release("move_forward")
		var ok: bool = cond.call()
		_results.append([label, ok])
		print("ROUTE %-24s %s (pos=%s)" % [label, "PASS" if ok else "FAIL", _player.global_position])
		_phase += 1
	elif _trace < 4 and (_frames - _phase_start) % 30 == 0:
		_trace += 1
		print("ROUTE trace phase=%d pos=%s vel=%s colls=%d" % [_phase, _player.global_position, _player.velocity, _player.get_slide_collision_count()])
		for i in _player.get_slide_collision_count():
			var c := _player.get_slide_collision(i)
			print("    collider=%s normal=%s point=%s" % [c.get_collider().name if c.get_collider() else "?", c.get_normal(), c.get_position()])


func _show_results() -> void:
	var fails := 0
	for r in _results:
		if not r[1]:
			fails += 1
	if fails == 0:
		print("ROUTE: ALL PASS")
		print("ROUTE: PASS")
	else:
		print("ROUTE: %d FAILURES" % fails)
		push_error("ROUTE: FAILURES PRESENT")
	get_tree().quit(1 if fails > 0 else 0)