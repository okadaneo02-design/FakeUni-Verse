extends Control
## Lobby: show roster, host starts the game, show URLs for browser players.

const WorldScene := preload("res://scenes/World.tscn")

var _roster: VBoxContainer
var _status: Label
var _start_btn: Button
var _host_info: Label

var _invite_edit: TextEdit
var _reply_edit: TextEdit
var _invite_btn: Button
var _connect_btn: Button
var _copy_btn: Button
var _webrtc_box: VBoxContainer


func _ready() -> void:
	_build_ui()
	Net.state_changed.connect(_refresh)
	Net.game_started.connect(_on_started)
	Signaling.invite_ready.connect(_on_invite_ready)
	Signaling.reply_ready.connect(_on_reply_ready)
	Signaling.failed.connect(func(r): _status.text = r)
	_refresh()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("141a26")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(520, 0)
	add_child(panel)
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
	title.text = "FAKEUNI-VERSE // LOBBY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("e8a33d"))
	vbox.add_child(title)

	var class_lbl := Label.new()
	class_lbl.text = "You are playing as %s" % Globals.CLASS_NAMES[Globals.my_class]
	class_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_lbl.add_theme_color_override("font_color", Globals.CLASS_COLORS[Globals.my_class])
	vbox.add_child(class_lbl)

	_roster = VBoxContainer.new()
	_roster.add_theme_constant_override("separation", 4)
	vbox.add_child(_roster)

	_host_info = Label.new()
	_host_info.text = ""
	_host_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_host_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_host_info.add_theme_font_size_override("font_size", 12)
	_host_info.add_theme_color_override("font_color", Color("8fd0a8"))
	vbox.add_child(_host_info)

	# ---- WebRTC invite/reply panel (browser mode) ----
	_webrtc_box = VBoxContainer.new()
	_webrtc_box.add_theme_constant_override("separation", 6)
	_webrtc_box.visible = Net.is_webrtc
	vbox.add_child(_webrtc_box)

	if Net.is_webrtc:
		if Net.is_host:
			_invite_btn = Button.new()
			_invite_btn.text = "NEW PLAYER INVITE (generate code)"
			_invite_btn.custom_minimum_size = Vector2(0, 40)
			_invite_btn.pressed.connect(_on_new_invite)
			_webrtc_box.add_child(_invite_btn)

			_invite_edit = TextEdit.new()
			_invite_edit.custom_minimum_size = Vector2(0, 90)
			_invite_edit.readonly = true
			_invite_edit.placeholder_text = "Invite code appears here - send it to the joining player."
			_webrtc_box.add_child(_invite_edit)

			var icopy := Button.new()
			icopy.text = "COPY INVITE CODE"
			icopy.pressed.connect(func(): DisplayServer.clipboard_set(_invite_edit.text))
			_webrtc_box.add_child(icopy)

			var rlabel := Label.new()
			rlabel.text = "Paste the player's REPLY code here:"
			_webrtc_box.add_child(rlabel)

			_reply_edit = TextEdit.new()
			_reply_edit.custom_minimum_size = Vector2(0, 70)
			_reply_edit.placeholder_text = "Reply code"
			_webrtc_box.add_child(_reply_edit)

			_connect_btn = Button.new()
			_connect_btn.text = "CONNECT PLAYER"
			_connect_btn.custom_minimum_size = Vector2(0, 40)
			_connect_btn.pressed.connect(_on_connect_player)
			_webrtc_box.add_child(_connect_btn)
		else:
			var rl := Label.new()
			rl.text = "Your REPLY code (send it to the host):"
			rl.add_theme_color_override("font_color", Color("46c6a5"))
			_webrtc_box.add_child(rl)

			_reply_edit = TextEdit.new()
			_reply_edit.custom_minimum_size = Vector2(0, 90)
			_reply_edit.readonly = true
			_webrtc_box.add_child(_reply_edit)

			_copy_btn = Button.new()
			_copy_btn.text = "COPY REPLY CODE"
			_copy_btn.pressed.connect(func(): DisplayServer.clipboard_set(_reply_edit.text))
			_webrtc_box.add_child(_copy_btn)

	_start_btn = Button.new()
	_start_btn.text = "START"
	_start_btn.custom_minimum_size = Vector2(0, 46)
	_start_btn.add_theme_font_size_override("font_size", 16)
	_start_btn.pressed.connect(_on_start)
	vbox.add_child(_start_btn)

	var back := Button.new()
	back.text = "BACK TO MENU"
	back.pressed.connect(_on_back)
	vbox.add_child(back)

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_color_override("font_color", Color("ff9a8a"))
	vbox.add_child(_status)


func _refresh() -> void:
	for child in _roster.get_children():
		child.queue_free()
	for id in Net.players:
		var info: Dictionary = Net.players[id]
		var row := HBoxContainer.new()
		var name_lbl := Label.new()
		name_lbl.text = info["name"]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cls_lbl := Label.new()
		var cls: int = info["class"]
		cls_lbl.text = Globals.CLASS_NAMES[cls]
		cls_lbl.add_theme_color_override("font_color", Globals.CLASS_COLORS[cls])
		var host_lbl := Label.new()
		host_lbl.text = " (HOST)" if id == 1 else ""
		host_lbl.add_theme_color_override("font_color", Color("8fd0a8"))
		row.add_child(name_lbl)
		row.add_child(cls_lbl)
		row.add_child(host_lbl)
		_roster.add_child(row)

	_start_btn.visible = Net.is_host
	if Net.is_webrtc and not Net.is_host:
		_start_btn.visible = false
	if Net.is_webrtc:
		if Net.is_host:
			_host_info.text = "HOST IN BROWSER: press NEW PLAYER INVITE for each joining player, send them the code, then paste their REPLY back to connect."
		else:
			_host_info.text = "Joined via invite. Copy your REPLY CODE and send it to the host."
	elif Net.is_host and Net.mode == "ws":
		var ip := "127.0.0.1"
		for a in IP.get_local_addresses():
			if a.begins_with("192.168.") or a.begins_with("10.") or a.begins_with("172."):
				ip = a
				break
		_host_info.text = "Tell players to JOIN with IP %s (or open http://%s:8080 in a browser to play in-browser)." % [ip, ip]
	else:
		_host_info.text = ""
	if Net.is_host:
		if Net.players.size() >= Globals.MAX_PLAYERS:
			_status.text = "Room full."
		else:
			_status.text = "%d/%d players" % [Net.players.size(), Globals.MAX_PLAYERS]
	else:
		_status.text = "Waiting for host to start the game..."


func _on_start() -> void:
	Net.start_game()


func _on_new_invite() -> void:
	if Net.players.size() >= Globals.MAX_PLAYERS:
		_status.text = "Room full."
		return
	var peer_id := Net.next_webrtc_peer_id()
	_status.text = "Generating invite for player %d..." % peer_id
	_invite_edit.text = ""
	if Signaling.host_start(Net.webrtc_mp(), peer_id):
		_invite_btn.disabled = true
	else:
		_status.text = "Could not generate invite."


func _on_invite_ready(code: String) -> void:
	_invite_edit.text = code
	_invite_btn.disabled = false
	_status.text = "Invite ready. Send the code to the joining player, then paste their reply below."


func _on_connect_player() -> void:
	var code := _reply_edit.text.strip_edges()
	if Signaling.host_apply_reply(code):
		_status.text = "Reply applied. Waiting for the player to connect..."
	else:
		_status.text = "Could not apply that reply code."


func _on_reply_ready(code: String) -> void:
	_reply_edit.text = code
	_status.text = "Reply code ready. Send it to the host, then wait for the host to paste it back."


func _on_back() -> void:
	Net.leave()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_started() -> void:
	# Host: try to serve the web build for browser players.
	if Net.is_host:
		var web_dir := ProjectSettings.globalize_path("res://build/web")
		if DirAccess.dir_exists_absolute(web_dir):
			HostServer.start(web_dir, 8080, Net.DEFAULT_PORT)
	get_tree().change_scene_to_packed(WorldScene)