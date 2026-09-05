extends Node3D
## Probes what geometry sits in front of the kitchen back door.

func _ready() -> void:
	Net.host(9090)
	var w := preload("res://scenes/World.tscn").instantiate()
	add_child(w)
	await get_tree().create_timer(0.5).timeout
	var space := get_world_3d().direct_space_state
	for y in [0.1, 0.4, 0.82, 1.3, 2.2]:
		var q := PhysicsRayQueryParameters3D.new()
		q.from = Vector3(11.5, y, 1.5)
		q.to = Vector3(11.5, y, -1.5)
		q.collision_mask = 1
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			print("y=", y, " clear")
		else:
			print("y=", y, " hit collider=", hit["collider"], " pos=", hit["position"], " normal=", hit["normal"])
	get_tree().quit(0)