class_name Player
extends CharacterBody3D
## First-person player controller.
## Two classes: TALL (1.4-1.5x normal human) and SHORT (0.6-0.7x normal human).
## Everything is built in code so the controller is self-contained.
##
## The node is CharacterBody3D. The camera rig, first-person arms, and the
## remote body (seen by other players) are children created at runtime.
##
## Multiplayer: each player node is owned by one peer. The owning peer runs
## movement locally and pushes its transform to everyone else via an
## unreliable RPC; remote peers interpolate.

signal interaction_changed(prompt: String)

const TALL := {
	"eye": 2.50, "body": 2.62, "radius": 0.40,
	"crouch_eye": 1.30, "crouch_body": 1.50,
	"walk": 3.4, "sprint": 5.6, "jump": 4.6,
}
const SHORT := {
	"eye": 1.10, "body": 1.22, "radius": 0.32,
	"crouch_eye": 0.55, "crouch_body": 0.72,
	"walk": 3.0, "sprint": 5.1, "jump": 5.4,
}

const SENSITIVITY := 0.0022
const ACCEL := 12.0
const AIR_ACCEL := 5.0
const FRICTION := 11.0
const GRAVITY := 16.0

var player_class := Globals.ClassType.TALL
var peer_id := 1

var _cfg: Dictionary = TALL
var _is_authority := true
var _class_scale := 1.0

var _body_height := 2.62
var _eye_height := 2.50
var _crouching := false
var _crouch_blend := 0.0

var _yaw_rot := 0.0
var _pitch := 0.0
var _pitch_limit := 1.45

var _fov_target := 76.0
const FOV_BASE := 76.0
const FOV_MIN := 50.0
const FOV_MAX := 95.0

var _cam: Camera3D
var _rig: Node3D
var _left_hand: Node3D
var _right_hand: Node3D
var _lower_body: Node3D
var _remote_body: Node3D
var _collision: CollisionShape3D
var _cam_ray: RayCast3D

var _bob_t := 0.0
var _land_t := 0.0
var _land_amp := 0.0
var _lean := 0.0
var _lean_target := 0.0
var _shake := 0.0

var _sync_timer := 0.0
var _target_pos := Vector3.ZERO
var _target_rot := 0.0
var _target_vel := Vector3.ZERO
var _target_crouch := 0.0
var _remote_initialized := false

var _facing_floor := false


func setup(p_id: int, p_class: int) -> void:
	peer_id = p_id
	player_class = p_class
	_cfg = TALL if p_class == Globals.ClassType.TALL else SHORT
	_class_scale = 1.0 if p_class == Globals.ClassType.TALL else 0.6
	_body_height = _cfg["body"]
	_eye_height = _cfg["eye"]
	set_multiplayer_authority(p_id)
	_is_authority = is_multiplayer_authority()


func _ready() -> void:
	_is_authority = is_multiplayer_authority()
	_build_body()
	_build_view()
	_target_pos = global_position
	_target_rot = global_rotation.y


func _build_body() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = _cfg["radius"]
	shape.height = _body_height
	_collision = CollisionShape3D.new()
	_collision.shape = shape
	add_child(_collision)
	collision_layer = 2
	collision_mask = 1 | 4

	_remote_body = _make_remote_body()
	add_child(_remote_body)


func _build_view() -> void:
	_rig = Node3D.new()
	_rig.name = "CameraRig"
	add_child(_rig)

	_cam = Camera3D.new()
	_cam.fov = 76.0
	_cam.near = 0.05
	_cam.far = 300.0
	_cam.current = _is_authority
	_rig.add_child(_cam)

	_cam_ray = RayCast3D.new()
	_cam_ray.target_position = Vector3(0, 0, -0.6)
	_cam_ray.collision_mask = 1 | 4
	_cam_ray.add_exception(self)
	_rig.add_child(_cam_ray)

	_build_arms()
	_build_lower_body()


func _build_arms() -> void:
	_left_hand = _make_hand(-0.20, -0.18)
	_right_hand = _make_hand(0.20, -0.18)
	_rig.add_child(_left_hand)
	_rig.add_child(_right_hand)


func _make_hand(side: float, vert: float) -> Node3D:
	var root := Node3D.new()
	var mesh := MeshInstance3D.new()
	mesh.mesh = _glove_mesh()
	mesh.material_override = _glove_mat()
	mesh.scale = Vector3.ONE * _class_scale
	root.add_child(mesh)
	root.position = Vector3(side, vert - 0.10, -0.42) * _class_scale
	root.rotation_degrees = Vector3(8, 0, -8.0 if side < 0 else 8.0)
	return root


func _glove_mesh() -> Mesh:
	var m := BoxMesh.new()
	m.size = Vector3(0.09, 0.11, 0.22)
	return m


func _glove_mat() -> Material:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("e9d8c2")
	m.roughness = 0.85
	return m


func _build_lower_body() -> void:
	_lower_body = Node3D.new()
	_lower_body.name = "LowerBody"
	_lower_body.scale = Vector3.ONE * _class_scale
	var torso := MeshInstance3D.new()
	torso.mesh = _unit_box()
	torso.material_override = _class_body_mat()
	torso.position = Vector3(0, -0.35, -0.06)
	torso.scale = Vector3(0.42, 0.5, 0.26)
	var lp := MeshInstance3D.new()
	lp.mesh = _unit_box()
	lp.material_override = _pants_mat()
	lp.position = Vector3(-0.12, -0.75, -0.04)
	lp.scale = Vector3(0.14, 0.4, 0.18)
	var rp := lp.duplicate()
	rp.position.x = 0.12
	_lower_body.add_child(torso)
	_lower_body.add_child(lp)
	_lower_body.add_child(rp)
	_rig.add_child(_lower_body)


func _make_remote_body() -> Node3D:
	var root := Node3D.new()
	root.name = "RemoteBody"
	root.scale = Vector3.ONE * _class_scale
	var torso := MeshInstance3D.new()
	torso.mesh = _unit_box()
	torso.material_override = _class_body_mat()
	torso.scale = Vector3(0.5, 0.75, 0.32)
	var head := MeshInstance3D.new()
	head.mesh = _unit_sphere()
	head.material_override = _skin_mat()
	head.scale = Vector3.ONE * (0.20 if player_class == Globals.ClassType.SHORT else 0.24)
	head.position = Vector3(0, 1.0, 0)
	root.add_child(torso)
	root.add_child(head)
	root.visible = false
	return root


func _class_body_mat() -> Material:
	var m := StandardMaterial3D.new()
	m.albedo_color = Globals.CLASS_COLORS[player_class].lerp(Color.WHITE, 0.25)
	m.roughness = 0.7
	return m


func _pants_mat() -> Material:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("3a4a5a")
	m.roughness = 0.9
	return m


func _skin_mat() -> Material:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("e8c39a")
	m.roughness = 0.7
	return m


func _unit_box() -> BoxMesh:
	var m := BoxMesh.new()
	m.size = Vector3.ONE
	return m


func _unit_sphere() -> SphereMesh:
	var m := SphereMesh.new()
	m.radius = 0.5
	m.height = 1.0
	return m


func _unhandled_input(event: InputEvent) -> void:
	if not _is_authority:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_yaw_rot -= event.relative.x * SENSITIVITY
		_pitch = clampf(_pitch - event.relative.y * SENSITIVITY, -_pitch_limit, _pitch_limit)
	elif event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_fov_target = clampf(_fov_target - 5.0, FOV_MIN, FOV_MAX)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_fov_target = clampf(_fov_target + 5.0, FOV_MIN, FOV_MAX)


func _physics_process(delta: float) -> void:
	if _is_authority:
		_physics_authority(delta)
		_send_sync(delta)
	else:
		_apply_remote_visuals()


func _physics_authority(delta: float) -> void:
	var was_floor := is_on_floor()
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir := (transform.basis * Vector3(input.x, 0, input.y)).normalized()

	var want_crouch: bool = Input.is_action_pressed("crouch")
	var want_sprint: bool = Input.is_action_pressed("sprint") and not want_crouch

	_crouch_blend = move_toward(_crouch_blend, 1.0 if want_crouch else 0.0, delta / 0.12)
	_update_shape_size()

	var target_speed: float = _cfg["walk"]
	if want_sprint and is_on_floor():
		target_speed = _cfg["sprint"]
	if _crouch_blend > 0.5:
		target_speed *= 0.5

	var vel := velocity
	if is_on_floor():
		var accel: float = ACCEL
		var target: Vector3 = wish_dir * target_speed
		vel.x = move_toward(vel.x, target.x, accel * delta)
		vel.z = move_toward(vel.z, target.z, accel * delta)
		if input.length() < 0.05:
			var fric := FRICTION
			vel.x = move_toward(vel.x, 0.0, fric * delta)
			vel.z = move_toward(vel.z, 0.0, fric * delta)
	else:
		var accel := AIR_ACCEL
		vel.x = move_toward(vel.x, wish_dir.x * _cfg["walk"] * 0.9, accel * delta)
		vel.z = move_toward(vel.z, wish_dir.z * _cfg["walk"] * 0.9, accel * delta)

	if not is_on_floor():
		vel.y -= GRAVITY * delta
	if Input.is_action_just_pressed("jump") and is_on_floor() and _crouch_blend < 0.5:
		vel.y = _cfg["jump"]

	velocity = vel
	move_and_slide()

	if is_on_floor() and not was_floor:
		var impact := clampf(-velocity.y * 0.25, 0.0, 1.0)
		_land_amp = impact
		_land_t = 0.0

	_apply_lean_from_collisions()
	_update_camera(delta)


func _apply_lean_from_collisions() -> void:
	_lean_target = 0.0
	for i in get_slide_collision_count():
		var n := get_slide_collision(i).get_normal()
		if n.y < 0.3:
			_lean_target = clampf(_lean_target - n.x * 0.35, -0.28, 0.28)


func _update_camera(delta: float) -> void:
	var moving: bool = is_on_floor() and velocity.length() > 0.4
	var speed: float = Vector2(velocity.x, velocity.z).length()

	_bob_t += (delta * (6.0 + speed * 1.4)) if moving else 0.0
	var bob_amp: float = 0.0
	if moving and _crouch_blend < 0.5:
		bob_amp = clampf(speed / _cfg["sprint"], 0.0, 1.0) * (0.030 if player_class == Globals.ClassType.TALL else 0.022)

	var bob_x: float = sin(_bob_t) * bob_amp * 0.5
	var bob_y: float = -abs(sin(_bob_t)) * bob_amp * 1.4

	if _land_t < 0.35:
		_land_t += delta
		bob_y += _land_amp * (1.0 - _land_t / 0.35) * -0.12

	_lean = lerpf(_lean, _lean_target, 1.0 - exp(-10.0 * delta))
	_shake = maxf(_shake - delta * 2.2, 0.0)

	var sh_x := randf_range(-1.0, 1.0) * _shake
	var sh_y := randf_range(-1.0, 1.0) * _shake

	_rig.position = Vector3(bob_x + sh_x, _eye_height + bob_y + sh_y, 0.0)
	_rig.rotation = Vector3(_pitch, 0.0, _lean + sh_x * 0.4)

	_cam.fov = lerpf(_cam.fov, _fov_target, 1.0 - exp(-12.0 * delta))

	if _cam_ray.is_colliding():
		var dist := _cam_ray.get_collision_point().distance_to(_cam_ray.global_position)
		if dist < 0.5:
			_cam.position.z = lerpf(_cam.position.z, -(0.5 - dist), 1.0 - exp(-20.0 * delta))
	else:
		_cam.position.z = lerpf(_cam.position.z, 0.0, 1.0 - exp(-20.0 * delta))

	var look_down := _pitch > 1.05
	_lower_body.visible = look_down and _facing_floor_check()

	_bob_hands(delta, bob_x, bob_y)


func _facing_floor_check() -> bool:
	return _pitch > 1.05


func _bob_hands(_delta: float, bob_x: float, bob_y: float) -> void:
	if _left_hand == null or _right_hand == null:
		return
	var hand_bob: float = -abs(sin(_bob_t)) * 0.03
	var s := _class_scale
	_left_hand.position.y = (-0.28 + bob_y * 0.5 + hand_bob) * s
	_right_hand.position.y = (-0.28 + bob_y * 0.5 + hand_bob) * s
	_left_hand.position.x = (-0.20 + bob_x) * s
	_right_hand.position.x = (0.20 + bob_x) * s


func _update_shape_size() -> void:
	var target_body := lerpf(_cfg["body"], _cfg["crouch_body"], _crouch_blend)
	var target_eye := lerpf(_cfg["eye"], _cfg["crouch_eye"], _crouch_blend)
	var shape: CapsuleShape3D = _collision.shape
	shape.height = lerpf(shape.height, target_body, 1.0 - exp(-18.0 * get_physics_process_delta_time()))
	_collision.position.y = shape.height * 0.5
	_eye_height = target_eye
	if _remote_body:
		_remote_body.position.y = 0.0
		var s: float = shape.height / _cfg["body"]
		_remote_body.scale = Vector3.ONE * maxf(0.35, s)


func _send_sync(delta: float) -> void:
	_sync_timer -= delta
	if _sync_timer <= 0.0:
		_sync_timer = 0.05
		rpc("_sync_state", global_position, global_rotation.y, velocity, _crouch_blend)


@rpc("authority", "call_remote", "unreliable")
func _sync_state(p: Vector3, rot: float, vel: Vector3, crouch: float) -> void:
	_target_pos = p
	_target_rot = rot
	_target_vel = vel
	_target_crouch = crouch


func _apply_remote_visuals() -> void:
	if not _remote_initialized:
		_remote_initialized = true
		_remote_body.visible = true
	var k := 1.0 - exp(-12.0 * get_physics_process_delta_time())
	global_position = global_position.lerp(_target_pos, k)
	var cr := global_rotation
	cr.y = lerp_angle(cr.y, _target_rot, k)
	global_rotation = cr
	if _remote_body:
		_remote_body.visible = true


func add_shake(amount: float) -> void:
	_shake = minf(_shake + amount, 0.6)


func notify_landing() -> void:
	pass
