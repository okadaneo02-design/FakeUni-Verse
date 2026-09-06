extends Control
## Main menu: name, class select, host or join.

const LobbyScene := preload("res://scenes/Lobby.tscn")

var _name_edit: LineEdit
var _class_buttons := {}
var _ip_edit: LineEdit
var _port_edit: LineEdit
var _status: Label
var _host_btn: Button
var _join_btn: Button
var _invite_edit: TextEdit


func _ready() -> void:
	_build_ui()
	Net.state_changed.connect(_on_net_state)
	_on_net_state()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("141a26")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	add_child(panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("1e2737")
	style.border_color = Color("3a4a63")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)
	_center_panel(panel, vbox)
	call_deferred("_center_panel", panel, vbox)
	resized.connect(func(): _center_panel(panel, vbox))

	var title := Label.new()
	title.text = "FAKEUNI-VERSE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color("e8a33d"))
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = "TALL CLASS  vs  SHORT CLASS"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color("46c6a5"))
	vbox.add_child(sub)

	var sub2 := Label.new()
	sub2.text = "One house. Two games. Choose your height."
	sub2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub2.add_theme_font_size_override("font_size", 13)
	sub2.add_theme_color_override("font_color", Color("8fa3bd"))
	vbox.add_child(sub2)

	vbox.add_child(_spacer(4))

	var name_row := HBoxContainer.new()
	vbox.add_child(name_row)
	var name_lbl := Label.new()
	name_lbl.text = "NAME"
	name_lbl.custom_minimum_size = Vector2(110, 0)
	name_row.add_child(name_lbl)
	_name_edit = LineEdit.new()
	_name_edit.text = Globals.player_name
	_name_edit.custom_minimum_size = Vector2(0, 34)
	_name_edit.max_length = 16
	name_row.add_child(_name_edit)
	_name_edit.text_changed.connect(func(t): Globals.player_name = t.strip_edges())

	vbox.add_child(_spacer(4))

	var class_lbl := Label.new()
	class_lbl.text = "CHOOSE YOUR CLASS"
	class_lbl.add_theme_color_override("font_color", Color("c9d4e4"))
	vbox.add_child(class_lbl)

	var class_row := HBoxContainer.new()
	class_row.add_theme_constant_override("separation", 10)
	vbox.add_child(class_row)
	for c in [Globals.ClassType.TALL, Globals.ClassType.SHORT]:
		var btn := Button.new()
		btn.text = Globals.CLASS_TITLES[c]
		btn.custom_minimum_size = Vector2(0, 48)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_class_pressed.bind(c))
		_class_buttons[c] = btn
		class_row.add_child(btn)

	var class_desc := Label.new()
	class_desc.text = "TALL: reach, strength, heavy objects.  SHORT: vents, floorboards, tiny spaces."
	class_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_desc.add_theme_font_size_override("font_size", 12)
	class_desc.add_theme_color_override("font_color", Color("6f83a0"))
	vbox.add_child(class_desc)

	vbox.add_child(_spacer(4))

	var mp_lbl := Label.new()
	mp_lbl.text = "LAN MODE (desktop host / WebSocket)"
	mp_lbl.add_theme_color_override("font_color", Color("c9d4e4"))
	vbox.add_child(mp_lbl)

	var ip_row := HBoxContainer.new()
	vbox.add_child(ip_row)
	var ip_lbl := Label.new()
	ip_lbl.text = "JOIN IP"
	ip_lbl.custom_minimum_size = Vector2(110, 0)
	ip_row.add_child(ip_lbl)
	_ip_edit = LineEdit.new()
	_ip_edit.text = "127.0.0.1"
	_ip_edit.placeholder_text = "host ip"
	_ip_edit.custom_minimum_size = Vector2(0, 34)
	ip_row.add_child(_ip_edit)

	var port_row := HBoxContainer.new()
	vbox.add_child(port_row)
	var port_lbl := Label.new()
	port_lbl.text = "PORT"
	port_lbl.custom_minimum_size = Vector2(110, 0)
	port_row.add_child(port_lbl)
	_port_edit = LineEdit.new()
	_port_edit.text = str(Net.DEFAULT_PORT)
	_port_edit.custom_minimum_size = Vector2(0, 34)
	_port_edit.max_length = 6
	port_row.add_child(_port_edit)

	_host_btn = Button.new()
	_host_btn.text = "HOST GAME"
	_host_btn.custom_minimum_size = Vector2(0, 46)
	_host_btn.add_theme_font_size_override("font_size", 16)
	_host_btn.pressed.connect(_on_host)
	_host_btn.visible = not OS.has_feature("web")
	vbox.add_child(_host_btn)

	_join_btn = Button.new()
	_join_btn.text = "JOIN DESKTOP HOST (WebSocket)"
	_join_btn.custom_minimum_size = Vector2(0, 46)
	_join_btn.add_theme_font_size_override("font_size", 14)
	_join_btn.pressed.connect(_on_join)
	vbox.add_child(_join_btn)

	vbox.add_child(_spacer(10))

	# ---- BROWSER MODE (WebRTC: host in the browser too) ----
	var web_lbl := Label.new()
	web_lbl.text = "BROWSER MODE (host in the browser too!)"
	web_lbl.add_theme_color_override("font_color", Color("46c6a5"))
	vbox.add_child(web_lbl)

	var web_row := HBoxContainer.new()
	web_row.add_theme_constant_override("separation", 10)
	vbox.add_child(web_row)

	var host_web_btn := Button.new()
	host_web_btn.text = "HOST IN BROWSER"
	host_web_btn.custom_minimum_size = Vector2(0, 44)
	host_web_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host_web_btn.add_theme_font_size_override("font_size", 14)
	host_web_btn.pressed.connect(_on_host_webrtc)
	web_row.add_child(host_web_btn)

	if OS.has_feature("web"):
		# browsers can join via invite codes
		_invite_edit = TextEdit.new()
		_invite_edit.custom_minimum_size = Vector2(0, 56)
		_invite_edit.placeholder_text = "Paste the host's INVITE code here"
		vbox.add_child(_invite_edit)

		var join_web_btn := Button.new()
		join_web_btn.text = "JOIN IN BROWSER (paste invite)"
		join_web_btn.custom_minimum_size = Vector2(0, 44)
		join_web_btn.add_theme_font_size_override("font_size", 14)
		join_web_btn.pressed.connect(_on_join_webrtc)
		vbox.add_child(join_web_btn)
		web_row.add_child(join_web_btn)
	else:
		var serve_btn := Button.new()
		serve_btn.text = "SERVER MODE (serve the page to browsers)"
		serve_btn.custom_minimum_size = Vector2(0, 44)
		serve_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		serve_btn.add_theme_font_size_override("font_size", 14)
		serve_btn.pressed.connect(_on_serve_only)
		web_row.add_child(serve_btn)

	var web_note := Label.new()
	web_note.text = "HOW IT WORKS: someone must serve the page (SERVER MODE in this app, or any static file server). Everyone opens the URL in a BROWSER. Then ANY browser can HOST IN BROWSER and others JOIN by pasting invite codes - no desktop host needed. On the same Wi-Fi it works instantly."
	web_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	web_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	web_note.add_theme_font_size_override("font_size", 11)
	web_note.add_theme_color_override("font_color", Color("6f83a0"))
	vbox.add_child(web_note)

	_status = Label.new()
	_status.text = ""
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_color_override("font_color", Color("ff9a8a"))
	vbox.add_child(_status)

	var note := Label.new()
	note.text = "NOTE: WebSocket HOST works only in the native app. Browsers can JOIN a desktop host too (enter its IP above)."
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 11)
	note.add_theme_color_override("font_color", Color("5b6f8c"))
	vbox.add_child(note)

	_update_class_buttons()


func _spacer(h: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s


func _center_panel(panel: Control, vbox: Control) -> void:
	var vp := get_viewport_rect().size
	var w := minf(vbox.get_combined_minimum_size().x + 24.0, vp.x - 16.0)
	var h := minf(vbox.get_combined_minimum_size().y + 24.0, vp.y - 16.0)
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -w / 2.0
	panel.offset_right = w / 2.0
	panel.offset_top = -h / 2.0
	panel.offset_bottom = h / 2.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH


func _on_class_pressed(c: int) -> void:
	Globals.my_class = c
	_update_class_buttons()


func _update_class_buttons() -> void:
	for c in _class_buttons:
		var btn: Button = _class_buttons[c]
		if c == Globals.my_class:
			btn.add_theme_stylebox_override("normal", _class_style(true, c))
			btn.add_theme_stylebox_override("hover", _class_style(true, c))
			btn.add_theme_stylebox_override("pressed", _class_style(true, c))
		else:
			btn.add_theme_stylebox_override("normal", _class_style(false, c))
			btn.add_theme_stylebox_override("hover", _class_style(false, c))
			btn.add_theme_stylebox_override("pressed", _class_style(false, c))


func _class_style(active: bool, c: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if active:
		s.bg_color = Globals.CLASS_COLORS[c].darkened(0.25)
		s.border_color = Globals.CLASS_COLORS[c]
		s.set_border_width_all(3)
	else:
		s.bg_color = Color("2a3550")
		s.border_color = Color("3a4a63")
		s.set_border_width_all(2)
	s.set_corner_radius_all(8)
	return s


func _on_host() -> void:
	var port := int(_port_edit.text)
	if port <= 0 or port > 65535:
		_status.text = "Invalid port."
		return
	_status.text = "Starting host..."
	if Net.host(port):
		get_tree().change_scene_to_packed(LobbyScene)
	else:
		_status.text = "Could not start host (port in use? native build required)."


func _on_host_webrtc() -> void:
	_status.text = "Starting browser host..."
	if Net.host_webrtc():
		get_tree().change_scene_to_packed(LobbyScene)
	else:
		_status.text = "WebRTC hosting failed (browser build required)."


func _on_join_webrtc() -> void:
	var code := _invite_edit.text.strip_edges()
	if code.is_empty():
		_status.text = "Paste the host's invite code first."
		return
	var parsed: Variant = JSON.parse_string(code)
	if not (parsed is Dictionary) or parsed.get("role", "") != "offer":
		_status.text = "That doesn't look like a valid invite code."
		return
	var peer_id := int(parsed.get("peer_id", 0))
	if peer_id < 2:
		_status.text = "Invite code is missing a peer id."
		return
	if not Net.join_webrtc(peer_id):
		_status.text = "Could not start the WebRTC join."
		return
	_status.text = "Connecting... (this takes a moment)"
	if Signaling.client_start(Net.webrtc_mp(), code):
		_join_btn.disabled = true
		_host_btn.disabled = true
		# wait for the reply code, then head to the lobby which shows it
		Signaling.reply_ready.connect(func(_c):
			get_tree().change_scene_to_packed(LobbyScene), CONNECT_ONE_SHOT)
		Signaling.failed.connect(func(reason):
			_status.text = "Join failed: %s" % reason, CONNECT_ONE_SHOT)
	else:
		_status.text = "Could not start the WebRTC join."


func _on_serve_only() -> void:
	var web_dir := ProjectSettings.globalize_path("res://build/web")
	if not DirAccess.dir_exists_absolute(web_dir):
		_status.text = "No web build found at build/web - nothing to serve."
		return
	HostServer.start(web_dir, 8080, Net.DEFAULT_PORT)
	_status.text = "SERVER MODE: page is live. Open http://localhost:8080 in a browser (or http://<this machine's IP>:8080 from other devices)."


func _on_join() -> void:
	var port := int(_port_edit.text)
	if port <= 0 or port > 65535:
		_status.text = "Invalid port."
		return
	_status.text = "Connecting to %s:%d..." % [_ip_edit.text, port]
	if not Net.join(_ip_edit.text, port):
		_status.text = "Connection failed to start."
	else:
		_join_btn.disabled = true
		_host_btn.disabled = true


func _on_net_state() -> void:
	# WebRTC clients transition to the lobby through the reply-code flow.
	if Net.connected and not Net.is_host and Net.mode != "webrtc":
		get_tree().change_scene_to_packed(LobbyScene)