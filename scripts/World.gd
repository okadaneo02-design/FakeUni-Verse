extends Node3D
## The game world: builds the house and manages players, HUD, pause.

const PlayerScene := preload("res://scenes/Player.tscn")
const MainScene := preload("res://scenes/Main.tscn")

const SPAWN_POINTS := [
	Vector3(10.6, 0.0, 14.6), Vector3(9.4, 0.0, 14.2), Vector3(12.2, 0.0, 14.2),
	Vector3(10.6, 0.0, 13.2), Vector3(9.4, 0.0, 12.8), Vector3(12.2, 0.0, 12.8),
]

var _house: Node3D
var _players := {}
var _local_id := 1
var _local_player: Player

var _hud_root: Control
var _hp_bar: ProgressBar
var _class_label: Label
var _objective_label: Label
var _event_label: Label
var _ping_label: Label
var _help_label: Label

var _paused := false
var _pause_menu: Control


func _ready() -> void:
	_house = Node3D.new()
	_house.name = "House"
	add_child(_house)
	var builder := HouseBuilder.new()
	builder.build(_house)

	var env := WorldEnvironment.new()
	env.environment = _make_env()
	add_child(env)

	_local_id = multiplayer.get_unique_id() if multiplayer.get_unique_id() != 0 else 1

	Net.state_changed.connect(_sync_players)
	_build_hud()
	_sync_players()

	if _local_player:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _make_env() -> Environment:
	var e := Environment.new()
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.45, 0.62, 0.85)
	sky_mat.sky_horizon_color = Color(0.82, 0.86, 0.9)
	sky_mat.ground_bottom_color = Color(0.25, 0.3, 0.28)
	sky_mat.ground_horizon_color = Color(0.7, 0.74, 0.72)
	sky_mat.sun_angle_max = 40.0
	sky.sky_material = sky_mat
	e.sky = sky
	e.background_mode = Environment.BG_SKY
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.8
	e.tonemap_mode = Environment.TONE_MAPPER_ACES
	e.fog_enabled = true
	e.fog_light_color = Color(0.7, 0.76, 0.8)
	e.fog_density = 0.006
	return e


func _sync_players() -> void:
	var want := Net.players.keys()
	for id in _players.keys():
		if not want.has(id):
			_players[id].queue_free()
			_players.erase(id)
	for id in want:
		if _players.has(id):
			continue
		var info: Dictionary = Net.players[id]
		var p: Player = PlayerScene.instantiate()
		_players[id] = p
		add_child(p)
		p.setup(id, int(info["class"]))
		var spawn: Vector3 = SPAWN_POINTS[(_players.size() - 1) % SPAWN_POINTS.size()]
		p.global_position = spawn
		p.global_rotation.y = 0.0
		if id == _local_id:
			_local_player = p
			p._cam.current = true
			_class_label.text = "CLASS: %s" % Globals.CLASS_NAMES[int(info["class"])]
			_class_label.add_theme_color_override("font_color", Globals.CLASS_COLORS[int(info["class"])])
	if _local_player == null and _players.has(_local_id):
		_local_player = _players[_local_id]


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)
	_hud_root = Control.new()
	_hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_hud_root)

	# HP bar (bottom-left)
	var hp_panel := PanelContainer.new()
	hp_panel.position = Vector2(20, 20)
	_hud_root.add_child(hp_panel)
	var hp_style := StyleBoxFlat.new()
	hp_style.bg_color = Color(0, 0, 0, 0.45)
	hp_style.set_corner_radius_all(6)
	hp_panel.add_theme_stylebox_override("panel", hp_style)
	var hp_box := VBoxContainer.new()
	hp_panel.add_child(hp_box)
	var hp_lbl := Label.new()
	hp_lbl.text = "HP"
	hp_lbl.add_theme_font_size_override("font_size", 11)
	hp_lbl.add_theme_color_override("font_color", Color("c9d4e4"))
	hp_box.add_child(hp_lbl)
	_hp_bar = ProgressBar.new()
	_hp_bar.max_value = 100.0
	_hp_bar.value = 100.0
	_hp_bar.custom_minimum_size = Vector2(180, 18)
	_hp_bar.show_percentage = true
	hp_box.add_child(_hp_bar)

	_class_label = Label.new()
	_class_label.text = "CLASS: -"
	_class_label.position = Vector2(20, 110)
	_class_label.add_theme_font_size_override("font_size", 16)
	_hud_root.add_child(_class_label)

	_objective_label = Label.new()
	_objective_label.text = "OBJECTIVE: Explore the house. Find the front door, the kitchen, and the basement stairs."
	_objective_label.position = Vector2(20, 140)
	_objective_label.add_theme_font_size_override("font_size", 13)
	_objective_label.add_theme_color_override("font_color", Color("e8e2d0"))
	_hud_root.add_child(_objective_label)

	_event_label = Label.new()
	_event_label.position = Vector2(20, 166)
	_event_label.add_theme_font_size_override("font_size", 12)
	_event_label.add_theme_color_override("font_color", Color("ffcf8a"))
	_hud_root.add_child(_event_label)

	_ping_label = Label.new()
	_ping_label.text = ""
	_ping_label.position = Vector2(20, 192)
	_ping_label.add_theme_font_size_override("font_size", 12)
	_ping_label.add_theme_color_override("font_color", Color("8fa3bd"))
	_hud_root.add_child(_ping_label)

	var help := Label.new()
	help.text = "WASD move | Mouse look | Shift sprint | Space jump | Ctrl crouch | Esc pause"
	help.position = Vector2(20, 220)
	help.add_theme_font_size_override("font_size", 12)
	help.add_theme_color_override("font_color", Color("8fa3bd"))
	_hud_root.add_child(help)

	# crosshair
	var cross := Label.new()
	cross.text = "+"
	cross.set_anchors_preset(Control.PRESET_CENTER)
	cross.add_theme_font_size_override("font_size", 26)
	cross.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	_hud_root.add_child(cross)

	_build_pause_menu()


func _build_pause_menu() -> void:
	_pause_menu = Control.new()
	_pause_menu.visible = false
	_hud_root.add_child(_pause_menu)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.5)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_menu.add_child(dim)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(320, 0)
	_pause_menu.add_child(panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("1e2737")
	style.border_color = Color("3a4a63")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title)
	var resume := Button.new()
	resume.text = "RESUME"
	resume.pressed.connect(_on_resume)
	vbox.add_child(resume)
	var leave := Button.new()
	leave.text = "LEAVE TO MENU"
	leave.pressed.connect(_on_leave)
	vbox.add_child(leave)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_set_paused(not _paused)


func _set_paused(p: bool) -> void:
	_paused = p
	_pause_menu.visible = p
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if p else Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = p


func _on_resume() -> void:
	_set_paused(false)


func _on_leave() -> void:
	_set_paused(false)
	Net.leave()
	get_tree().change_scene_to_packed(MainScene)


func _process(_delta: float) -> void:
	if _local_player and _hp_bar:
		_hp_bar.value = 100.0
	if _local_player:
		_ping_label.text = "POS %.1f %.1f %.1f" % [_local_player.global_position.x, _local_player.global_position.y, _local_player.global_position.z]