extends Node3D
const WorldScene := preload("res://scenes/World.tscn")
var _frames := 0
var _world: Node

func _ready() -> void:
	Net.host(9090)
	_world = WorldScene.instantiate()
	add_child(_world)

func _physics_process(_delta: float) -> void:
	_frames += 1
	if _frames != 10:
		return
	var space := get_world_3d().direct_space_state
	for y in [0.5, 1.1, 1.14, 1.3, 1.5]:
		var q := PhysicsRayQueryParameters3D.new()
		q.from = Vector3(11.0, y, 14.0)
		q.to = Vector3(11.0, y, 11.0)
		q.collision_mask = 1
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			print("y=", y, " clear")
		else:
			print("y=", y, " hit ", hit["collider"].name, " at ", hit["position"], " normal=", hit["normal"])
	get_tree().quit(0)
