extends Node3D
## Headless client test: joins a host and reports roster state.

func _ready() -> void:
	Globals.player_name = "ClientBot"
	Globals.my_class = Globals.ClassType.SHORT
	print("CLIENT: joining 127.0.0.1:9090")
	if not Net.join("127.0.0.1", 9090):
		push_error("CLIENT: join failed")
		get_tree().quit(1)
		return
	Net.state_changed.connect(_on_state)
	Net.game_started.connect(func(): print("CLIENT: game started signal"))


func _on_state() -> void:
	if Net.connected:
		print("CLIENT: connected, my_id=", multiplayer.get_unique_id(), " players=", Net.players)
		if Net.players.size() >= 2:
			print("CLIENT: PASS")
			get_tree().quit(0)


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() > 15000:
		push_error("CLIENT: timed out")
		get_tree().quit(1)