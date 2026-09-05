extends Node
## Network manager: host / join, roster, game start.
## Browsers (web export) can only act as clients (WebSocket client).
## The native build can host (WebSocket server) and serve the web build over HTTP.

signal state_changed
signal player_joined(peer_id: int, info: Dictionary)
signal player_left(peer_id: int)
signal game_started

const DEFAULT_PORT := 9090

var peer: WebSocketMultiplayerPeer = null
var is_host := false
var connected := false
var players := {}
var mode := ""            # "", "ws", "webrtc"
var is_webrtc := false

var _listening_port := DEFAULT_PORT
var _next_webrtc_id := 2


func _process(_delta: float) -> void:
	if peer:
		peer.poll()


func host(port: int = DEFAULT_PORT) -> bool:
	if OS.has_feature("web"):
		push_error("Browsers cannot host a WebSocket game. Use HOST IN BROWSER (WebRTC) instead.")
		return false
	_listening_port = port
	peer = WebSocketMultiplayerPeer.new()
	var err := peer.create_server(port)
	if err != OK:
		push_error("Failed to start host on port %d: %s" % [port, error_string(err)])
		peer = null
		return false
	multiplayer.multiplayer_peer = peer
	mode = "ws"
	is_host = true
	connected = true
	players[1] = _self_info()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	state_changed.emit()
	return true


## Browser-hosted game: this peer is the WebRTC "server" (id 1).
func host_webrtc() -> bool:
	if not OS.has_feature("web"):
		push_error("WebRTC hosting is for the browser build. In the native app, use HOST GAME (WebSocket).")
		return false
	var rtc := WebRTCMultiplayerPeer.new()
	rtc.create_server()
	multiplayer.multiplayer_peer = rtc
	peer = null
	mode = "webrtc"
	is_webrtc = true
	is_host = true
	connected = true
	_next_webrtc_id = 2
	players[1] = _self_info()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	state_changed.emit()
	return true


## Browser client: joins the host's WebRTC session with the id from the invite.
func join_webrtc(peer_id: int) -> bool:
	if not OS.has_feature("web"):
		push_error("WebRTC joining is for the browser build.")
		return false
	var rtc := WebRTCMultiplayerPeer.new()
	var err := rtc.create_client(peer_id)
	if err != OK:
		push_error("Failed to create WebRTC client: %s" % error_string(err))
		return false
	multiplayer.multiplayer_peer = rtc
	peer = null
	mode = "webrtc"
	is_webrtc = true
	is_host = false
	connected = true
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	state_changed.emit()
	return true


func webrtc_mp() -> WebRTCMultiplayerPeer:
	if mode == "webrtc":
		return multiplayer.multiplayer_peer as WebRTCMultiplayerPeer
	return null


func next_webrtc_peer_id() -> int:
	var id := _next_webrtc_id
	_next_webrtc_id += 1
	return id


func join(ip: String, port: int = DEFAULT_PORT) -> bool:
	_listening_port = port
	peer = WebSocketMultiplayerPeer.new()
	var err := peer.create_client("ws://%s:%d" % [ip, port])
	if err != OK:
		push_error("Failed to connect to %s:%d: %s" % [ip, port, error_string(err)])
		peer = null
		return false
	multiplayer.multiplayer_peer = peer
	is_host = false
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	state_changed.emit()
	return true


func leave() -> void:
	if peer:
		peer.close()
		peer = null
	var mp := multiplayer.multiplayer_peer
	if mp and mp is WebRTCMultiplayerPeer:
		mp.close()
	multiplayer.multiplayer_peer = null
	is_host = false
	connected = false
	is_webrtc = false
	mode = ""
	players.clear()
	state_changed.emit()


func start_game() -> void:
	if not is_host:
		push_warning("Only the host can start the game.")
		return
	_start.rpc()


func _self_info() -> Dictionary:
	return { "name": Globals.player_name, "class": Globals.my_class }


func _on_peer_connected(id: int) -> void:
	_hello.rpc_id(id, _self_info())


func _on_connected_to_server() -> void:
	connected = true
	_hello.rpc_id(1, _self_info())
	state_changed.emit()


func _on_connection_failed() -> void:
	connected = false
	state_changed.emit()


func _on_peer_disconnected(id: int) -> void:
	if is_host and players.has(id):
		players.erase(id)
		player_left.emit(id)
		_broadcast_roster()


@rpc("any_peer", "call_local", "reliable")
func _hello(info: Dictionary) -> void:
	if is_host:
		var sender := multiplayer.get_remote_sender_id()
		if sender == 1:
			return
		if players.size() >= Globals.MAX_PLAYERS:
			_kick.rpc_id(sender)
			return
		players[sender] = info
		player_joined.emit(sender, info)
		_broadcast_roster()


@rpc("any_peer", "call_remote", "reliable")
func _roster(r: Dictionary) -> void:
	players = r
	state_changed.emit()


func _broadcast_roster() -> void:
	_roster.rpc(players)
	state_changed.emit()


@rpc("any_peer", "call_remote", "reliable")
func _kick() -> void:
	pass


@rpc("any_peer", "call_local", "reliable")
func _start() -> void:
	game_started.emit()
