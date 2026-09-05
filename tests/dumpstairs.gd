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
	var house := _world.get_node("House")
	for c in house.get_children():
		if c is StaticBody3D and c.get_child_count() > 20:
			print("BODY ", c.name)
			for s in c.get_children():
				if s is CollisionShape3D and s.shape is BoxShape3D:
					var p: Vector3 = s.global_transform.origin
					if true:
						print("   size=", s.shape.size, " pos=", p)
	get_tree().quit(0)
