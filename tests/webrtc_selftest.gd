extends Node3D
## WebRTC self-test: runs the full SDP offer/answer + ICE exchange with two
## local peers in the same page. Only meaningful in the browser build.
## Prints SELFTEST lines; exits 0 on pass.

var _h: WebRTCPeerConnection
var _c: WebRTCPeerConnection
var _offer := ""
var _answer := ""
var _h_ice: Array = []
var _c_ice: Array = []


func _ready() -> void:
	_run()


func _process(_delta: float) -> void:
	if _h:
		_h.poll()
	if _c:
		_c.poll()


func _run() -> void:
	print("SELFTEST: begin")
	_h = WebRTCPeerConnection.new()
	_c = WebRTCPeerConnection.new()
	var eh := _h.initialize({ "iceServers": [] })
	var ec := _c.initialize({ "iceServers": [] })
	if eh != OK or ec != OK:
		print("SELFTEST: FAIL initialize host=%s client=%s" % [error_string(eh), error_string(ec)])
		_done(false)
		return

	_h.session_description_created.connect(_on_host_session)
	_c.session_description_created.connect(_on_client_session)
	_h.ice_candidate_created.connect(func(mid, idx, sdp): _h_ice.append([mid, idx, sdp]))
	_c.ice_candidate_created.connect(func(mid, idx, sdp): _c_ice.append([mid, idx, sdp]))

	var dc := _h.create_data_channel("test")
	if dc == null:
		print("SELFTEST: FAIL could not create data channel")
		_done(false)
		return
	print("SELFTEST: data channel created")

	var offer_err: Variant = _h.create_offer()
	print("SELFTEST: create_offer returned ", offer_err)
	for i in range(10):
		await get_tree().create_timer(0.5).timeout
		if not _offer.is_empty():
			break
	if _offer.is_empty():
		print("SELFTEST: FAIL no offer produced")
		_done(false)
		return
	print("SELFTEST: offer ok len=%d ice=%d" % [_offer.length(), _h_ice.size()])

	_c.set_remote_description("offer", _offer)
	for ic in _h_ice:
		_c.add_ice_candidate(ic[0], ic[1], ic[2])
	_c.create_answer()
	for i in range(10):
		await get_tree().create_timer(0.5).timeout
		if not _answer.is_empty():
			break
	if _answer.is_empty():
		print("SELFTEST: FAIL no answer produced")
		_done(false)
		return
	print("SELFTEST: answer ok len=%d ice=%d" % [_answer.length(), _c_ice.size()])

	_h.set_remote_description("answer", _answer)
	for ic in _c_ice:
		_h.add_ice_candidate(ic[0], ic[1], ic[2])

	for i in range(60):
		await get_tree().create_timer(0.25).timeout
		var hs: int = _h.get_connection_state()
		var cs: int = _c.get_connection_state()
		if i % 4 == 0:
			print("SELFTEST: state host=%d client=%d" % [hs, cs])
		if hs == WebRTCPeerConnection.STATE_CONNECTED and cs == WebRTCPeerConnection.STATE_CONNECTED:
			print("SELFTEST: PASS")
			_done(true)
			return
		if hs >= WebRTCPeerConnection.STATE_FAILED or cs >= WebRTCPeerConnection.STATE_FAILED:
			break
	print("SELFTEST: FAIL connection never established")
	_done(false)


func _on_host_session(t: String, sdp: String) -> void:
	print("SELFTEST: host session type=", t, " len=", sdp.length())
	_h.set_local_description(t, sdp)
	if t == "offer":
		_offer = sdp


func _on_client_session(t: String, sdp: String) -> void:
	print("SELFTEST: client session type=", t, " len=", sdp.length())
	_c.set_local_description(t, sdp)
	if t == "answer":
		_answer = sdp


func _done(passed: bool) -> void:
	get_tree().quit(0 if passed else 1)