extends Node
## WebRTC signaling for browser-hosted multiplayer.
## Browsers cannot listen for connections, but they CAN be WebRTC peers.
## Signaling (the SDP offer/answer + ICE exchange) happens through
## copy-paste codes: the host generates an INVITE code, the joining player
## pastes it and gets a REPLY code, which the host pastes back.

signal invite_ready(code: String)
signal reply_ready(code: String)
signal failed(reason: String)

const ICE_SERVERS := [
	{ "urls": ["stun:stun.l.google.com:19302", "stun:stun1.l.google.com:19302"] },
]

var _pc: WebRTCPeerConnection = null
var _mp: WebRTCMultiplayerPeer = null
var _mode := ""           # "host" or "client"
var _peer_id := 0
var _cands: Array = []
var _collecting := false
var _collect_time := 0.0
var _last_reply := ""
var _last_invite := ""
var _last_sdp := ""
var _last_type := ""


func _process(delta: float) -> void:
	if _collecting:
		_collect_time += delta
		if _collect_time > 1.2:
			_collecting = false
			_finish_collection()


func make_pc() -> WebRTCPeerConnection:
	var pc := WebRTCPeerConnection.new()
	var err := pc.initialize({ "iceServers": ICE_SERVERS })
	if err != OK:
		push_error("[Signaling] WebRTC unavailable on this build: %s" % error_string(err))
		return null
	pc.session_description_created.connect(_on_session)
	pc.ice_candidate_created.connect(_on_ice)
	return pc


## HOST: start an invite for a new player (creates pc + offer).
func host_start(mp: WebRTCMultiplayerPeer, peer_id: int) -> bool:
	if _pc != null:
		failed.emit("Finish the previous invite first.")
		return false
	_mp = mp
	_peer_id = peer_id
	_mode = "host"
	_cands = []
	_pc = make_pc()
	if _pc == null:
		return false
	var err := mp.add_peer(_pc, peer_id)
	if err != OK:
		failed.emit("Could not add peer: %s" % error_string(err))
		_pc = null
		return false
	_pc.create_offer()
	_collecting = true
	_collect_time = 0.0
	return true


## HOST: apply the joining player's reply code.
func host_apply_reply(code: String) -> bool:
	var d := _parse(code)
	if d.is_empty() or d.get("role", "") != "answer" or _pc == null:
		failed.emit("That doesn't look like a reply code.")
		return false
	_pc.set_remote_description("answer", d["sdp"])
	for c in d.get("ice", []):
		_pc.add_ice_candidate(c[0], c[1], c[2])
	_cleanup()
	print("[Signaling] reply applied, waiting for the data channels to open")
	return true


## CLIENT: paste the host's invite code, generate the reply.
func client_start(mp: WebRTCMultiplayerPeer, invite: String) -> bool:
	if _pc != null:
		failed.emit("Already joining a game.")
		return false
	var d := _parse(invite)
	if d.is_empty() or d.get("role", "") != "offer":
		failed.emit("That doesn't look like an invite code.")
		return false
	_mp = mp
	_peer_id = int(d.get("peer_id", 0))
	_mode = "client"
	_cands = []
	_last_invite = invite
	_pc = make_pc()
	if _pc == null:
		return false
	var err := mp.add_peer(_pc, 1)
	if err != OK:
		failed.emit("Could not add peer: %s" % error_string(err))
		_pc = null
		return false
	_pc.set_remote_description("offer", d["sdp"])
	for c in d.get("ice", []):
		_pc.add_ice_candidate(c[0], c[1], c[2])
	_pc.create_answer()
	_collecting = true
	_collect_time = 0.0
	return true


func _on_session(type: String, sdp: String) -> void:
	if _pc == null:
		return
	_last_type = type
	_last_sdp = sdp
	_pc.set_local_description(type, sdp)


func _on_ice(mid: String, index: int, sdp: String) -> void:
	if _collecting:
		_cands.append([mid, index, sdp])


func _finish_collection() -> void:
	if _pc == null:
		return
	var code := JSON.stringify({
		"v": 1,
		"role": "answer" if _mode == "client" else "offer",
		"peer_id": _peer_id,
		"sdp": _last_sdp,
		"ice": _cands,
	})
	if _mode == "client":
		_last_reply = code
		reply_ready.emit(code)
	else:
		invite_ready.emit(code)


func _parse(code: String) -> Dictionary:
	if code.strip_edges().is_empty():
		return {}
	var d: Variant = JSON.parse_string(code.strip_edges())
	if d is Dictionary:
		return d
	return {}


func _cleanup() -> void:
	_pc = null
	_mp = null
	_mode = ""
	_cands = []
	_collecting = false


func last_reply() -> String:
	return _last_reply