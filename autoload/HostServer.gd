extends Node
## Minimal HTTP/1.1 static file server so the native host can serve the web
## export to browsers on the same network. Native builds only.

var tcp: TCPServer = null
var enabled := false
var web_dir := ""
var http_port := 8080
var ws_port := 9090
var _conns := {}


func start(web_dir_path: String, http_port_val: int = 8080, ws_port_val: int = 9090) -> void:
	if OS.has_feature("web"):
		return
	http_port = http_port_val
	ws_port = ws_port_val
	web_dir = web_dir_path
	if not DirAccess.dir_exists_absolute(web_dir):
		push_warning("[HostServer] web build dir not found: %s" % web_dir)
		return
	tcp = TCPServer.new()
	var err := tcp.listen(http_port)
	if err != OK:
		push_error("[HostServer] could not listen on %d: %s" % [http_port, error_string(err)])
		tcp = null
		return
	enabled = true
	var ip := _lan_ip()
	print("[HostServer] Serving web build at:")
	print("    http://%s:%d/   (open in a browser on the same network)" % [ip, http_port])
	print("    http://localhost:%d/ (this machine)" % http_port)
	print("    Game server: ws://%s:%d" % [ip, ws_port])


func _process(_delta: float) -> void:
	if not enabled or tcp == null:
		return
	while tcp.is_connection_available():
		var c := tcp.take_connection()
		c.set_no_delay(true)
		_conns[c] = { "data": "" }
	for c in _conns.keys():
		match c.get_status():
			StreamPeerTCP.STATUS_CONNECTED:
				c.poll()
				var avail: int = c.get_available_bytes()
				if avail > 0:
					var res: Array = c.get_data(avail)
					if res[0] == OK:
						_conns[c]["data"] += res[1].get_string_from_utf8()
						_handle(c, _conns[c])
			StreamPeerTCP.STATUS_ERROR, StreamPeerTCP.STATUS_NONE:
				_conns.erase(c)
		if not _conns.has(c):
			continue


func _handle(c: StreamPeerTCP, state: Dictionary) -> void:
	var data: String = state["data"]
	var idx := data.find("\r\n\r\n")
	if idx == -1:
		if data.length() > 65536:
			state["data"] = ""
		return
	state["data"] = ""
	var head := data.substr(0, idx)
	var lines := head.split("\r\n")
	if lines.is_empty():
		_close(c)
		return
	var parts := lines[0].split(" ")
	if parts.size() < 2:
		_close(c)
		return
	var method := parts[0]
	var path := parts[1]
	if method != "GET" and method != "HEAD":
		_respond(c, 405, "text/plain; charset=utf-8", "method not allowed")
		return
	path = path.split("?")[0]
	if path == "/":
		path = "/index.html"
	if path.find("..") != -1:
		_respond(c, 400, "text/plain", "bad request")
		return
	var safe := web_dir.path_join(path.trim_prefix("/"))
	var file := FileAccess.open(safe, FileAccess.READ)
	if file == null:
		_respond(c, 404, "text/plain; charset=utf-8", "not found")
		return
	var content := file.get_buffer(file.get_length())
	file.close()
	_respond_bytes(c, 200, _mime(safe), content)


func _respond(c: StreamPeerTCP, code: int, mime: String, body: String) -> void:
	_respond_bytes(c, code, mime, body.to_utf8_buffer())


func _respond_bytes(c: StreamPeerTCP, code: int, mime: String, body: PackedByteArray) -> void:
	var reason := "OK"
	if code != 200:
		reason = "ERR"
	var head := "HTTP/1.1 %d %s\r\n" % [code, reason]
	head += "Content-Type: %s\r\n" % mime
	head += "Content-Length: %d\r\n" % body.size()
	head += "Connection: close\r\n"
	head += "Cache-Control: no-cache\r\n"
	head += "Cross-Origin-Opener-Policy: same-origin\r\n"
	head += "Cross-Origin-Embedder-Policy: require-corp\r\n"
	head += "\r\n"
	c.put_data(head.to_utf8_buffer())
	if body.size() > 0:
		c.put_data(body)
	_close(c)


func _close(c: StreamPeerTCP) -> void:
	c.disconnect_from_host()
	_conns.erase(c)


func _mime(path: String) -> String:
	if path.ends_with(".html"): return "text/html; charset=utf-8"
	if path.ends_with(".js"): return "text/javascript; charset=utf-8"
	if path.ends_with(".wasm"): return "application/wasm"
	if path.ends_with(".pck"): return "application/octet-stream"
	if path.ends_with(".png"): return "image/png"
	if path.ends_with(".jpg") or path.ends_with(".jpeg"): return "image/jpeg"
	if path.ends_with(".svg"): return "image/svg+xml"
	if path.ends_with(".css"): return "text/css; charset=utf-8"
	if path.ends_with(".json"): return "application/json"
	if path.ends_with(".ico"): return "image/x-icon"
	return "application/octet-stream"


func _lan_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return "127.0.0.1"
