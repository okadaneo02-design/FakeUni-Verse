extends Node3D
## Renders screenshots of key locations for visual QA.

const WorldScene := preload("res://scenes/World.tscn")

var spots := [
	[Vector3(11.0, 0.0, 14.0), 0.0, "foyer"],
	[Vector3(16.5, 0.0, 12.0), 2.2, "living"],
	[Vector3(4.0, 0.0, 7.4), 0.0, "dining"],
	[Vector3(12.0, 0.0, 3.2), 2.0, "kitchen"],
	[Vector3(10.3, 0.0, 9.5), 3.0, "hallway"],
	[Vector3(10.5, 3.2, 12.0), 0.0, "up_hallway"],
	[Vector3(16.5, 3.2, 13.5), 2.2, "master"],
	[Vector3(12.0, 3.2, 2.0), 2.0, "office"],
	[Vector3(10.2, 6.4, 10.0), 0.0, "attic"],
	[Vector3(6.0, -3.0, 8.0), 2.0, "basement"],
	[Vector3(24.0, 0.0, 6.0), 2.2, "garage"],
	[Vector3(11.0, 0.0, -2.0), 0.6, "backyard"],
	[Vector3(11.0, 0.0, 17.6), 2.8, "porch"],
]
var idx := 0
var frame := 0
var _player: Player


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("/tmp/shots")
	Net.host(9090)
	var w := WorldScene.instantiate()
	add_child(w)


func _process(_delta: float) -> void:
	frame += 1
	if frame < 90:
		return
	if _player == null:
		_player = get_node_or_null("World").get("_local_player") if get_node_or_null("World") else null
		return
	if idx >= spots.size():
		get_tree().quit(0)
		return
	_player.global_position = spots[idx][0]
	_player.global_rotation = Vector3(0, spots[idx][1], 0)
	_player.velocity = Vector3.ZERO
	if frame % 150 == 0:
		var img := get_viewport().get_texture().get_image()
		var path := "/tmp/shots/%02d_%s.png" % [idx, spots[idx][2]]
		img.save_png(path)
		print("SHOT %s -> %s" % [spots[idx][2], path])
		idx += 1