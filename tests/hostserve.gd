extends Node3D
## Tests the built-in HTTP server that serves the web build.

func _ready() -> void:
	print("HOSTSERVE: starting")
	HostServer.start(ProjectSettings.globalize_path("res://build/web"), 8080, 9090)


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() > 25000:
		print("HOSTSERVE: PASS")
		get_tree().quit(0)