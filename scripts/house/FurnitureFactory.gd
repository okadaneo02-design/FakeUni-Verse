class_name FurnitureFactory
## Populates every room of the house with furniture and props.
## Uses HouseBuilder's helpers; all pieces are static (movable props come later).

static func populate(b: HouseBuilder, house: Node3D) -> void:
	var rooms := {}
	for room_def in b.ROOMS:
		rooms[room_def[0]] = room_def

	var groups := {
		"foyer": _foyer,
		"living": _living,
		"den": _den,
		"hallway": _hallway,
		"dining": _dining,
		"kitchen": _kitchen,
		"pantry": _pantry,
		"bathroom": _bathroom,
		"laundry": _laundry,
		"utility": _utility,
		"mudroom": _mudroom,
		"garage": _garage,
		"up_hallway": _up_hallway,
		"master": _master,
		"bedroom2": _bedroom2,
		"bedroom3": _bedroom3,
		"office": _office,
		"up_bathroom": _up_bathroom,
		"up_closet": _up_closet,
		"attic": _attic,
		"bs_main": _bs_main,
		"bs_boiler": _bs_boiler,
		"bs_elec": _bs_elec,
		"bs_crawl": _bs_crawl,
	}
	for room_name in groups:
		var sb := StaticBody3D.new()
		sb.name = "furn_" + room_name
		sb.collision_layer = 1
		sb.collision_mask = 0
		var floor_idx: int = rooms[room_name][5]
		sb.position.y = {0: 0.0, 1: 3.2, 2: -3.0, 3: 6.4}[floor_idx]
		house.add_child(sb)
		groups[room_name].call(b, sb)


# ---------------------------------------------------------------- helpers

static func _b(b: HouseBuilder, sb: StaticBody3D, size: Vector3, pos: Vector3, mat: String, rot: float = 0.0) -> void:
	b.box(sb, size, pos, mat, rot, sb)


static func _m(b: HouseBuilder, sb: StaticBody3D, size: Vector3, pos: Vector3, mat: String, rot: float = 0.0) -> void:
	b.mesh_box(sb, size, pos, mat, rot)


static func _s(b: HouseBuilder, sb: StaticBody3D, r: float, pos: Vector3, mat: String) -> void:
	b.mesh_sphere(sb, r, pos, mat)


static func _c(b: HouseBuilder, sb: StaticBody3D, r: float, h: float, pos: Vector3, mat: String, rot_x: float = 0.0) -> void:
	b.mesh_cyl(sb, r, h, pos, mat, rot_x)


# ---------------------------------------------------------------- rooms

static func _foyer(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(2.2, 0.03, 1.6), Vector3(11.0, 0.02, 13.6), "carpet_red")
	_b(b, sb, Vector3(0.5, 1.7, 0.5), Vector3(9.75, 0.85, 15.1), "wood_dark")
	_b(b, sb, Vector3(0.5, 1.7, 0.5), Vector3(9.75, 0.85, 14.55), "wood_dark")
	_b(b, sb, Vector3(0.06, 0.1, 0.5), Vector3(9.75, 1.78, 14.82), "metal")
	_s(b, sb, 0.04, Vector3(9.75, 1.85, 14.82), "metal_dark")
	_b(b, sb, Vector3(1.3, 0.45, 0.45), Vector3(12.55, 0.225, 15.35), "wood_light")
	_b(b, sb, Vector3(1.3, 0.05, 0.45), Vector3(12.55, 0.475, 15.35), "linen")
	_b(b, sb, Vector3(0.4, 0.9, 0.4), Vector3(9.4, 0.45, 15.2), "wood_dark")
	_s(b, sb, 0.06, Vector3(9.4, 0.95, 15.2), "plant")
	_b(b, sb, Vector3(0.35, 1.1, 0.35), Vector3(12.55, 0.55, 12.7), "plant")
	_b(b, sb, Vector3(0.05, 0.9, 0.05), Vector3(12.55, 1.1, 12.7), "wood_dark")
	_s(b, sb, 0.2, Vector3(12.55, 1.35, 12.7), "plant")
	_b(b, sb, Vector3(0.06, 0.5, 0.02), Vector3(9.12, 1.25, 14.8), "white")
	_b(b, sb, Vector3(0.06, 0.02, 0.35), Vector3(9.12, 1.5, 14.8), "frame")


static func _living(b: HouseBuilder, sb: StaticBody3D) -> void:
	# sectional couch along the north wall
	_b(b, sb, Vector3(3.0, 0.55, 1.1), Vector3(15.2, 0.275, 15.35), "fabric_teal")
	_b(b, sb, Vector3(1.1, 0.55, 1.4), Vector3(16.8, 0.275, 15.35), "fabric_teal")
	_b(b, sb, Vector3(3.0, 0.35, 0.9), Vector3(15.2, 0.5, 14.95), "fabric_teal")
	_b(b, sb, Vector3(0.6, 0.2, 0.6), Vector3(14.6, 0.65, 15.45), "linen")
	_b(b, sb, Vector3(0.6, 0.2, 0.6), Vector3(16.9, 0.65, 15.45), "linen")
	_b(b, sb, Vector3(2.0, 0.45, 1.0), Vector3(16.5, 0.225, 13.0), "wood_light")
	_b(b, sb, Vector3(0.7, 0.05, 0.45), Vector3(16.5, 0.5, 13.0), "glass")
	# armchairs
	_b(b, sb, Vector3(0.95, 0.6, 0.95), Vector3(13.6, 0.3, 14.2), "fabric_gold")
	_b(b, sb, Vector3(0.95, 0.6, 0.95), Vector3(19.4, 0.3, 14.2), "fabric_red")
	# TV cabinet + TV on south wall
	_b(b, sb, Vector3(2.0, 0.5, 0.5), Vector3(16.5, 0.25, 8.7), "wood_dark")
	_b(b, sb, Vector3(1.5, 0.9, 0.1), Vector3(16.5, 0.95, 8.42), "metal_dark")
	# bookshelf on east wall
	_b(b, sb, Vector3(0.45, 1.9, 1.1), Vector3(19.65, 0.95, 11.2), "wood_dark")
	for i in range(4):
		_b(b, sb, Vector3(0.42, 0.04, 0.95), Vector3(19.65, 0.3 + i * 0.5, 11.2), "wood_light")
	_b(b, sb, Vector3(0.32, 0.3, 0.7), Vector3(19.65, 0.7, 11.2), "fabric_red")
	_b(b, sb, Vector3(0.25, 0.02, 0.5), Vector3(19.65, 0.55, 11.2), "white")
	# rug
	_b(b, sb, Vector3(2.8, 0.02, 3.6), Vector3(16.5, 0.01, 13.0), "carpet")
	# floor lamps
	for lx in [13.9, 19.1]:
		_c(b, sb, 0.03, 1.5, Vector3(lx, 0.75, 9.6), "metal_dark")
		_s(b, sb, 0.12, Vector3(lx, 1.55, 9.6), "white")
	# curtains at the east windows
	for wz in [10.3, 13.7]:
		_b(b, sb, Vector3(0.05, 2.0, 0.9), Vector3(19.86, 1.0, wz), "fabric_slate")
	# wall art
	_b(b, sb, Vector3(0.05, 0.6, 0.8), Vector3(13.12, 1.7, 11.0), "white")
	_b(b, sb, Vector3(0.06, 0.45, 0.6), Vector3(13.12, 1.7, 11.0), "toy")


static func _den(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(2.6, 0.55, 1.0), Vector3(4.5, 0.275, 12.3), "fabric_slate")
	_b(b, sb, Vector3(0.7, 0.35, 0.8), Vector3(4.5, 0.5, 11.9), "fabric_slate")
	_b(b, sb, Vector3(1.0, 0.5, 0.5), Vector3(3.6, 0.25, 11.6), "fabric_gold")
	_b(b, sb, Vector3(1.0, 0.5, 0.5), Vector3(5.4, 0.25, 11.6), "fabric_gold")
	_b(b, sb, Vector3(1.2, 0.45, 0.6), Vector3(4.5, 0.225, 13.4), "wood_light")
	_b(b, sb, Vector3(1.8, 0.5, 0.45), Vector3(4.5, 0.25, 15.55), "wood_dark")
	_b(b, sb, Vector3(1.3, 0.75, 0.08), Vector3(4.5, 0.75, 15.25), "metal_dark")
	_b(b, sb, Vector3(0.45, 1.8, 0.9), Vector3(0.65, 0.9, 10.6), "wood_dark")
	_b(b, sb, Vector3(0.45, 1.8, 0.9), Vector3(0.65, 0.9, 15.4), "wood_dark")
	_b(b, sb, Vector3(2.6, 0.02, 2.4), Vector3(4.5, 0.01, 13.2), "carpet_blue")
	for lx in [2.2, 6.8]:
		_c(b, sb, 0.03, 1.4, Vector3(lx, 0.7, 11.2), "metal_dark")
		_s(b, sb, 0.11, Vector3(lx, 1.45, 11.2), "white")
	_s(b, sb, 0.22, Vector3(8.4, 0.55, 15.2), "plant")


static func _hallway(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.4, 0.02, 3.4), Vector3(10.5, 0.01, 9.5), "carpet_blue")
	_b(b, sb, Vector3(1.2, 0.85, 0.4), Vector3(10.5, 0.425, 7.5), "wood_light")
	_b(b, sb, Vector3(0.9, 0.03, 0.36), Vector3(10.5, 0.87, 7.5), "glass")
	_s(b, sb, 0.05, Vector3(10.95, 0.95, 7.5), "plant")
	_b(b, sb, Vector3(0.04, 0.7, 0.5), Vector3(8.16, 1.35, 10.6), "frame")
	_b(b, sb, Vector3(0.06, 0.02, 0.5), Vector3(8.16, 1.05, 10.6), "frame")
	_b(b, sb, Vector3(0.6, 0.7, 0.04), Vector3(9.8, 0.9, 8.18), "door_wood")


static func _dining(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.9, 0.08, 1.1), Vector3(4.0, 0.74, 7.4), "wood_light")
	_b(b, sb, Vector3(1.7, 0.02, 0.9), Vector3(4.0, 0.8, 7.4), "linen")
	_b(b, sb, Vector3(0.1, 0.72, 0.1), Vector3(3.1, 0.36, 7.4), "wood_dark")
	_b(b, sb, Vector3(0.1, 0.72, 0.1), Vector3(4.9, 0.36, 7.4), "wood_dark")
	_b(b, sb, Vector3(0.1, 0.72, 0.1), Vector3(4.0, 0.36, 6.6), "wood_dark")
	_b(b, sb, Vector3(0.1, 0.72, 0.1), Vector3(4.0, 0.36, 8.2), "wood_dark")
	for i in range(6):
		var a := i * PI / 3.0 + PI / 6.0
		var px := 4.0 + sin(a) * 1.5
		var pz := 7.4 + cos(a) * 1.05
		_b(b, sb, Vector3(0.45, 0.08, 0.45), Vector3(px, 0.44, pz), "wood_light", rad_to_deg(a))
		_c(b, sb, 0.035, 0.44, Vector3(px - 0.13, 0.22, pz - 0.13), "metal_dark")
		_c(b, sb, 0.035, 0.44, Vector3(px + 0.13, 0.22, pz + 0.13), "metal_dark")
		_b(b, sb, Vector3(0.42, 0.05, 0.42), Vector3(px, 0.49, pz), "linen")
	_b(b, sb, Vector3(1.6, 0.9, 0.4), Vector3(4.0, 0.45, 9.6), "wood_dark")
	_b(b, sb, Vector3(1.5, 0.02, 0.35), Vector3(4.0, 0.93, 9.6), "white")
	_s(b, sb, 0.05, Vector3(3.2, 1.0, 9.6), "plant")
	_b(b, sb, Vector3(3.4, 0.02, 2.2), Vector3(4.0, 0.01, 7.5), "carpet_red")
	_b(b, sb, Vector3(0.05, 0.5, 0.7), Vector3(7.9, 1.25, 6.2), "white")


static func _kitchen(b: HouseBuilder, sb: StaticBody3D) -> void:
	# north counters (between doors)
	_b(b, sb, Vector3(2.2, 0.92, 0.62), Vector3(9.6, 0.46, 0.52), "counter")
	_b(b, sb, Vector3(1.2, 0.92, 0.62), Vector3(13.3, 0.46, 0.52), "counter")
	# sink in the counter
	_b(b, sb, Vector3(0.55, 0.03, 0.45), Vector3(13.3, 0.93, 0.52), "metal")
	# stove + oven on the east counter
	_b(b, sb, Vector3(2.2, 0.95, 0.62), Vector3(15.1, 0.48, 4.5), "counter")
	_b(b, sb, Vector3(0.9, 0.06, 0.55), Vector3(15.1, 0.97, 4.5), "metal_dark")
	_b(b, sb, Vector3(0.9, 0.9, 0.62), Vector3(15.1, 0.55, 6.1), "appliance")
	_b(b, sb, Vector3(0.9, 0.9, 0.62), Vector3(15.1, 0.55, 7.6) - Vector3(0,0,0), "appliance")
	# fridge
	_b(b, sb, Vector3(0.95, 1.85, 0.75), Vector3(8.75, 0.925, 0.6), "appliance")
	_b(b, sb, Vector3(0.95, 0.5, 0.75), Vector3(8.75, 0.25, 0.6), "appliance")
	# island
	_b(b, sb, Vector3(2.8, 0.92, 1.2), Vector3(12.0, 0.46, 3.1), "counter")
	_b(b, sb, Vector3(2.2, 0.02, 0.8), Vector3(12.0, 0.93, 3.1), "wood_light")
	for i in range(2):
		var sx := 11.2 + i * 1.6
		_b(b, sb, Vector3(0.4, 0.75, 0.4), Vector3(sx, 0.375, 2.0), "wood_dark")
		_b(b, sb, Vector3(0.38, 0.04, 0.38), Vector3(sx, 0.77, 2.0), "linen")
	# kitchen table + chairs
	_b(b, sb, Vector3(1.3, 0.07, 0.85), Vector3(9.7, 0.735, 4.8), "wood_light")
	_b(b, sb, Vector3(0.09, 0.7, 0.09), Vector3(9.15, 0.35, 4.8), "wood_dark")
	_b(b, sb, Vector3(0.09, 0.7, 0.09), Vector3(10.25, 0.35, 4.8), "wood_dark")
	_b(b, sb, Vector3(0.09, 0.7, 0.09), Vector3(9.7, 0.35, 4.35), "wood_dark")
	_b(b, sb, Vector3(0.09, 0.7, 0.09), Vector3(9.7, 0.35, 5.25), "wood_dark")
	for i in range(4):
		var px := 9.7 + (1.0 if i % 2 == 0 else -1.0) * 0.95
		var pz := 4.8 + (0.0 if i < 2 else 0.9 if i == 2 else -0.9)
		_b(b, sb, Vector3(0.42, 0.06, 0.42), Vector3(px, 0.45, pz), "wood_light")
		_c(b, sb, 0.03, 0.44, Vector3(px, 0.22, pz), "metal_dark")
	# upper cabinets
	for cx in [8.9, 9.9, 12.9]:
		_b(b, sb, Vector3(0.8, 0.7, 0.32), Vector3(cx, 2.1, 0.42), "wood_light")
	_b(b, sb, Vector3(1.9, 0.7, 0.32), Vector3(15.1, 2.1, 4.5), "wood_light")
	# hanging utensils
	for ux in [12.9, 13.5]:
		_c(b, sb, 0.012, 0.3, Vector3(ux, 1.9, 0.42), "metal")
	# microwave
	_b(b, sb, Vector3(0.55, 0.35, 0.45), Vector3(14.3, 1.45, 4.5), "appliance")
	# plant on the counter
	_b(b, sb, Vector3(0.3, 0.25, 0.3), Vector3(8.85, 1.05, 0.52), "toy")
	_s(b, sb, 0.14, Vector3(8.85, 1.25, 0.52), "plant")
	# rug
	_b(b, sb, Vector3(2.0, 0.02, 1.2), Vector3(12.0, 0.01, 5.2), "carpet")
	# bin
	_b(b, sb, Vector3(0.35, 0.6, 0.35), Vector3(15.85, 0.3, 2.2), "metal")
	# trash under sink side
	_b(b, sb, Vector3(0.3, 0.5, 0.3), Vector3(12.1, 0.25, 6.55), "metal_dark")
	# towels hanging
	_b(b, sb, Vector3(0.02, 0.5, 0.3), Vector3(8.18, 1.2, 3.2), "linen")


static func _pantry(b: HouseBuilder, sb: StaticBody3D) -> void:
	for i in range(3):
		_b(b, sb, Vector3(1.8, 0.04, 0.6), Vector3(14.6, 0.35 + i * 0.55, 1.3), "wood_light")
	_b(b, sb, Vector3(0.3, 0.35, 0.3), Vector3(14.1, 0.6, 1.3), "toy")
	_b(b, sb, Vector3(0.3, 0.35, 0.3), Vector3(14.6, 0.6, 1.3), "white")
	_b(b, sb, Vector3(0.3, 0.35, 0.3), Vector3(15.1, 0.6, 1.3), "frame")
	_b(b, sb, Vector3(0.25, 0.3, 0.25), Vector3(14.35, 1.15, 1.3), "toy")
	_b(b, sb, Vector3(0.25, 0.3, 0.25), Vector3(14.85, 1.15, 1.3), "white")
	_b(b, sb, Vector3(0.6, 1.7, 0.6), Vector3(15.55, 0.85, 1.9), "wood_dark")
	_b(b, sb, Vector3(0.55, 1.5, 0.55), Vector3(13.85, 0.75, 2.55), "appliance")


static func _bathroom(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(0.45, 0.42, 0.35), Vector3(19.4, 0.21, 3.3), "white")
	_b(b, sb, Vector3(0.4, 0.1, 0.32), Vector3(19.4, 0.47, 3.3), "wood_light")
	_b(b, sb, Vector3(1.0, 0.85, 0.5), Vector3(17.0, 0.425, 0.6), "white")
	_b(b, sb, Vector3(0.9, 0.02, 0.4), Vector3(17.0, 0.87, 0.6), "glass")
	_b(b, sb, Vector3(0.05, 0.6, 0.35), Vector3(17.0, 1.4, 0.6), "frame")
	_b(b, sb, Vector3(1.7, 0.55, 0.75), Vector3(18.5, 0.275, 3.4), "white")
	_b(b, sb, Vector3(1.6, 0.02, 0.65), Vector3(18.5, 0.56, 3.4), "glass")
	_b(b, sb, Vector3(0.06, 0.06, 1.2), Vector3(18.5, 0.7, 3.4), "metal")
	_b(b, sb, Vector3(0.7, 0.6, 0.4), Vector3(16.35, 0.3, 3.3), "white")
	_s(b, sb, 0.04, Vector3(16.35, 0.62, 3.3), "metal_dark")
	_b(b, sb, Vector3(0.35, 0.3, 0.3), Vector3(16.8, 0.15, 2.2), "linen")
	_b(b, sb, Vector3(0.04, 0.8, 0.5), Vector3(16.18, 1.4, 0.9), "linen")
	_s(b, sb, 0.05, Vector3(16.18, 1.0, 0.9), "white")


static func _laundry(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(0.8, 1.0, 0.7), Vector3(5.7, 0.5, 0.6), "appliance")
	_b(b, sb, Vector3(0.8, 1.0, 0.7), Vector3(6.8, 0.5, 0.6), "appliance")
	_b(b, sb, Vector3(1.9, 0.04, 0.5), Vector3(6.0, 1.08, 0.6), "counter")
	_b(b, sb, Vector3(0.5, 0.4, 0.5), Vector3(6.0, 0.2, 3.2), "linen")
	_b(b, sb, Vector3(0.4, 0.4, 0.4), Vector3(6.9, 0.2, 3.2), "toy")
	_b(b, sb, Vector3(0.6, 1.2, 0.3), Vector3(5.25, 0.6, 2.5), "metal")
	_b(b, sb, Vector3(0.4, 0.5, 0.4), Vector3(7.7, 0.25, 3.6), "wood_light")
	_b(b, sb, Vector3(0.04, 0.5, 0.6), Vector3(7.9, 1.1, 2.0), "linen")


static func _utility(b: HouseBuilder, sb: StaticBody3D) -> void:
	_c(b, sb, 0.45, 1.6, Vector3(4.4, 0.8, 0.8), "appliance")
	_c(b, sb, 0.02, 1.6, Vector3(4.4, 0.8, 0.2), "pipes")
	_b(b, sb, Vector3(1.4, 0.04, 0.5), Vector3(4.3, 2.6, 3.2), "wood_light")
	_b(b, sb, Vector3(0.9, 0.5, 0.5), Vector3(4.2, 0.25, 3.4), "wood_dark")
	_b(b, sb, Vector3(0.8, 0.5, 0.5), Vector3(3.2, 0.25, 3.6), "wood_dark")
	_b(b, sb, Vector3(0.5, 0.9, 0.5), Vector3(4.6, 0.45, 4.6), "appliance")
	_c(b, sb, 0.05, 0.6, Vector3(2.4, 0.7, 0.7), "pipes", 90.0)
	_c(b, sb, 0.04, 0.8, Vector3(2.4, 0.4, 1.4), "pipes")
	_s(b, sb, 0.04, Vector3(3.0, 0.9, 2.0), "plant")


static func _mudroom(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.5, 0.45, 0.4), Vector3(17.4, 0.225, 7.6), "wood_light")
	_b(b, sb, Vector3(1.5, 0.05, 0.4), Vector3(17.4, 0.475, 7.6), "linen")
	_b(b, sb, Vector3(1.2, 0.5, 0.03), Vector3(17.4, 1.3, 7.8), "wood_dark")
	_b(b, sb, Vector3(0.5, 0.3, 0.9), Vector3(18.6, 0.15, 7.6), "wood_dark")
	_b(b, sb, Vector3(0.5, 0.3, 0.9), Vector3(19.5, 0.15, 7.5), "wood_dark")
	_b(b, sb, Vector3(0.4, 1.2, 0.35), Vector3(16.4, 0.6, 5.0), "metal")
	_b(b, sb, Vector3(0.4, 1.2, 0.35), Vector3(16.4, 0.6, 5.8), "metal_dark")


static func _garage(b: HouseBuilder, sb: StaticBody3D) -> void:
	# the family car (static for now)
	_b(b, sb, Vector3(4.4, 0.6, 1.9), Vector3(24.0, 0.3, 6.0), "car_red")
	_b(b, sb, Vector3(2.0, 0.42, 1.7), Vector3(24.0, 0.81, 6.0), "glass")
	_b(b, sb, Vector3(4.4, 0.15, 0.2), Vector3(24.0, 0.55, 7.1), "car_dark")
	for wx in [22.6, 25.4]:
		for wz in [5.3, 6.7]:
			_c(b, sb, 0.33, 0.18, Vector3(wx, 0.09, wz), "car_dark")
	# workbench
	_b(b, sb, Vector3(2.4, 0.08, 0.8), Vector3(25.4, 0.84, 0.7), "wood_dark")
	_b(b, sb, Vector3(0.08, 0.8, 0.8), Vector3(24.3, 0.4, 0.7), "wood_dark")
	_b(b, sb, Vector3(0.08, 0.8, 0.8), Vector3(26.5, 0.4, 0.7), "wood_dark")
	# shelves + storage
	_b(b, sb, Vector3(1.6, 1.6, 0.4), Vector3(27.5, 0.8, 1.2), "metal")
	for i in range(4):
		_b(b, sb, Vector3(1.55, 0.03, 0.38), Vector3(27.5, 0.35 + i * 0.4, 1.2), "wood_light")
	_b(b, sb, Vector3(0.6, 0.5, 0.6), Vector3(21.2, 0.25, 10.4), "wood_light")
	_b(b, sb, Vector3(0.6, 0.5, 0.6), Vector3(22.1, 0.25, 10.5), "wood_light")
	_b(b, sb, Vector3(0.6, 0.5, 0.6), Vector3(23.0, 0.25, 10.4), "wood_light")
	_b(b, sb, Vector3(0.7, 0.4, 0.7), Vector3(26.6, 0.2, 10.9), "toy")
	# tool cabinet
	_b(b, sb, Vector3(0.5, 1.7, 0.6), Vector3(20.7, 0.85, 1.2), "metal_dark")
	_b(b, sb, Vector3(0.5, 1.7, 0.6), Vector3(20.7, 0.85, 2.1), "metal")
	# bicycles (two, against the south wall)
	for bx in [21.4, 22.5]:
		_c(b, sb, 0.28, 0.06, Vector3(bx, 0.55, 11.3), "metal")
		_c(b, sb, 0.28, 0.06, Vector3(bx - 0.35, 0.5, 11.3), "metal")
		_b(b, sb, Vector3(0.06, 0.6, 0.7), Vector3(bx + 0.1, 0.8, 11.3), "metal")
	# oil drums
	for dx in [24.6, 25.4]:
		_c(b, sb, 0.28, 0.85, Vector3(dx, 0.425, 10.9), "toy")
	# box fan
	_b(b, sb, Vector3(0.45, 0.5, 0.2), Vector3(27.6, 0.25, 9.2), "appliance")
	# lawn mower
	_b(b, sb, Vector3(0.9, 0.4, 0.5), Vector3(24.2, 0.2, 11.4), "toy")
	_c(b, sb, 0.2, 0.1, Vector3(24.1, 0.05, 11.5), "car_dark")
	_c(b, sb, 0.2, 0.1, Vector3(24.7, 0.05, 11.5), "car_dark")
	# tire stack
	for i in range(3):
		_c(b, sb, 0.3, 0.18, Vector3(20.9, 0.09 + i * 0.18, 9.2), "car_dark")


static func _up_hallway(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.3, 0.02, 4.2), Vector3(10.5, 0.01, 12.0), "carpet_blue")
	_b(b, sb, Vector3(1.1, 0.85, 0.4), Vector3(10.4, 0.425, 15.4), "wood_light")
	_s(b, sb, 0.06, Vector3(10.9, 0.95, 15.4), "plant")
	_b(b, sb, Vector3(0.04, 0.65, 0.5), Vector3(8.16, 1.3, 14.5), "white")
	_b(b, sb, Vector3(0.4, 0.4, 0.3), Vector3(8.4, 1.5, 14.5), "toy")


static func _master(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.6, 0.12, 2.2), Vector3(16.5, 0.28, 14.4), "wood_dark")
	_b(b, sb, Vector3(1.7, 0.25, 2.25), Vector3(16.5, 0.46, 14.4), "linen")
	_b(b, sb, Vector3(1.5, 0.08, 2.1), Vector3(16.5, 0.64, 14.4), "fabric_teal")
	_b(b, sb, Vector3(1.6, 0.06, 0.35), Vector3(16.5, 0.72, 15.55), "wood_dark")
	_b(b, sb, Vector3(1.6, 0.06, 0.35), Vector3(16.5, 0.72, 13.25), "wood_dark")
	# pillows
	_b(b, sb, Vector3(0.6, 0.14, 0.35), Vector3(15.6, 0.72, 15.5), "linen")
	_b(b, sb, Vector3(0.6, 0.14, 0.35), Vector3(17.4, 0.72, 15.5), "linen")
	_b(b, sb, Vector3(0.5, 0.4, 0.5), Vector3(14.7, 0.2, 14.3), "wood_light")
	_b(b, sb, Vector3(0.5, 0.4, 0.5), Vector3(18.3, 0.2, 14.3), "wood_light")
	_s(b, sb, 0.05, Vector3(14.7, 0.5, 14.3), "white")
	_s(b, sb, 0.05, Vector3(18.3, 0.5, 14.3), "white")
	# wardrobe
	_b(b, sb, Vector3(1.3, 2.0, 0.6), Vector3(13.35, 1.0, 13.2), "wood_dark")
	# dresser + TV
	_b(b, sb, Vector3(1.7, 0.85, 0.5), Vector3(16.5, 0.425, 8.55), "wood_dark")
	_b(b, sb, Vector3(1.2, 0.55, 0.08), Vector3(16.5, 1.1, 8.3), "metal_dark")
	# desk
	_b(b, sb, Vector3(1.2, 0.07, 0.6), Vector3(19.45, 0.735, 8.9), "wood_light")
	_b(b, sb, Vector3(0.07, 0.7, 0.07), Vector3(18.95, 0.35, 8.9), "wood_dark")
	_b(b, sb, Vector3(0.07, 0.7, 0.07), Vector3(19.95, 0.35, 8.9), "wood_dark")
	_b(b, sb, Vector3(0.5, 0.06, 0.5), Vector3(19.45, 0.8, 9.3), "linen")
	# rug
	_b(b, sb, Vector3(2.4, 0.02, 3.4), Vector3(16.5, 0.01, 12.6), "carpet_red")
	# floor lamp
	_c(b, sb, 0.03, 1.5, Vector3(14.0, 0.75, 9.3), "metal_dark")
	_s(b, sb, 0.11, Vector3(14.0, 1.55, 9.3), "white")
	_s(b, sb, 0.25, Vector3(19.5, 0.6, 15.2), "plant")
	# curtains
	_b(b, sb, Vector3(0.05, 2.0, 1.0), Vector3(19.86, 1.0, 10.8), "fabric_slate")
	_b(b, sb, Vector3(0.05, 2.0, 1.0), Vector3(19.86, 1.0, 13.2), "fabric_slate")
	_b(b, sb, Vector3(2.0, 0.05, 0.9), Vector3(16.2, 1.95, 15.86), "fabric_slate")


static func _bedroom2(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.4, 0.12, 1.9), Vector3(4.0, 0.28, 14.3), "wood_dark")
	_b(b, sb, Vector3(1.5, 0.22, 1.95), Vector3(4.0, 0.45, 14.3), "linen")
	_b(b, sb, Vector3(1.3, 0.07, 1.8), Vector3(4.0, 0.61, 14.3), "fabric_red")
	_b(b, sb, Vector3(0.5, 0.38, 0.5), Vector3(2.8, 0.19, 14.6), "wood_light")
	_b(b, sb, Vector3(0.5, 0.38, 0.5), Vector3(5.2, 0.19, 14.6), "wood_light")
	_s(b, sb, 0.05, Vector3(2.8, 0.48, 14.6), "white")
	# wardrobe
	_b(b, sb, Vector3(1.1, 1.9, 0.55), Vector3(0.65, 0.95, 12.5), "wood_dark")
	# dresser
	_b(b, sb, Vector3(1.3, 0.8, 0.45), Vector3(5.3, 0.4, 8.55), "wood_dark")
	# desk
	_b(b, sb, Vector3(1.1, 0.07, 0.55), Vector3(7.45, 0.735, 13.2), "wood_light")
	_b(b, sb, Vector3(0.4, 0.5, 0.4), Vector3(7.6, 0.25, 13.4), "toy")
	# toys
	_b(b, sb, Vector3(0.4, 0.3, 0.3), Vector3(1.8, 0.15, 11.0), "toy")
	_b(b, sb, Vector3(0.3, 0.25, 0.3), Vector3(1.2, 0.125, 11.6), "toy")
	# rug
	_b(b, sb, Vector3(2.0, 0.02, 2.6), Vector3(4.0, 0.01, 12.0), "carpet_blue")
	_s(b, sb, 0.2, Vector3(0.9, 0.6, 15.4), "plant")


static func _bedroom3(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.4, 0.12, 1.9), Vector3(4.0, 0.28, 1.7), "wood_dark")
	_b(b, sb, Vector3(1.5, 0.22, 1.95), Vector3(4.0, 0.45, 1.7), "linen")
	_b(b, sb, Vector3(1.3, 0.07, 1.8), Vector3(4.0, 0.61, 1.7), "fabric_gold")
	_b(b, sb, Vector3(0.5, 0.38, 0.5), Vector3(2.8, 0.19, 2.0), "wood_light")
	_b(b, sb, Vector3(0.5, 0.38, 0.5), Vector3(5.2, 0.19, 2.0), "wood_light")
	_b(b, sb, Vector3(1.1, 1.9, 0.55), Vector3(0.65, 0.95, 4.5), "wood_dark")
	_b(b, sb, Vector3(1.1, 0.07, 0.55), Vector3(7.45, 0.735, 6.4), "wood_light")
	_b(b, sb, Vector3(0.05, 1.7, 0.9), Vector3(0.66, 0.85, 7.0), "wood_dark")
	_b(b, sb, Vector3(1.6, 0.02, 1.9), Vector3(4.0, 0.01, 4.5), "carpet")
	_s(b, sb, 0.03, Vector3(2.8, 0.62, 6.5), "white")
	_s(b, sb, 0.03, Vector3(5.2, 0.62, 6.5), "white")


static func _office(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.8, 0.07, 0.9), Vector3(12.0, 0.735, 1.6), "wood_dark")
	_b(b, sb, Vector3(0.08, 0.72, 0.08), Vector3(11.2, 0.36, 1.6), "wood_dark")
	_b(b, sb, Vector3(0.08, 0.72, 0.08), Vector3(12.8, 0.36, 1.6), "wood_dark")
	_b(b, sb, Vector3(1.7, 0.02, 0.85), Vector3(12.0, 0.78, 1.6), "linen")
	_b(b, sb, Vector3(0.6, 0.45, 0.05), Vector3(11.4, 1.0, 1.2), "metal_dark")
	_b(b, sb, Vector3(0.6, 0.45, 0.05), Vector3(12.6, 1.0, 1.2), "metal_dark")
	_b(b, sb, Vector3(0.3, 0.3, 0.08), Vector3(12.0, 1.05, 1.2), "metal_dark")
	# office chair
	_c(b, sb, 0.16, 0.12, Vector3(12.0, 0.06, 2.5), "car_dark")
	_c(b, sb, 0.02, 0.5, Vector3(12.0, 0.37, 2.5), "metal")
	_b(b, sb, Vector3(0.5, 0.08, 0.5), Vector3(12.0, 0.66, 2.5), "car_dark")
	_b(b, sb, Vector3(0.5, 0.55, 0.08), Vector3(12.0, 0.98, 2.42), "car_dark")
	# bookshelves
	for sz in [2.4, 5.2]:
		_b(b, sb, Vector3(0.4, 1.8, 0.9), Vector3(8.35, 0.9, sz), "wood_dark")
		for i in range(4):
			_b(b, sb, Vector3(0.38, 0.03, 0.8), Vector3(8.35, 0.35 + i * 0.45, sz), "wood_light")
	# filing cabinet
	_b(b, sb, Vector3(0.5, 1.2, 0.5), Vector3(15.6, 0.6, 7.3), "metal")
	_b(b, sb, Vector3(0.5, 1.2, 0.5), Vector3(15.6, 0.6, 6.6), "metal_dark")
	_b(b, sb, Vector3(1.4, 0.02, 2.0), Vector3(12.0, 0.01, 4.5), "carpet")
	_s(b, sb, 0.25, Vector3(15.5, 0.6, 1.8), "plant")
	_b(b, sb, Vector3(0.05, 0.5, 0.6), Vector3(8.12, 1.3, 3.8), "white")


static func _up_bathroom(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(0.45, 0.42, 0.35), Vector3(19.35, 0.21, 4.6), "white")
	_b(b, sb, Vector3(0.4, 0.1, 0.32), Vector3(19.35, 0.47, 4.6), "wood_light")
	_b(b, sb, Vector3(1.7, 0.55, 0.75), Vector3(18.5, 0.275, 7.5), "white")
	_b(b, sb, Vector3(1.6, 0.02, 0.65), Vector3(18.5, 0.56, 7.5), "glass")
	_b(b, sb, Vector3(0.9, 0.8, 0.45), Vector3(16.55, 0.4, 7.4), "white")
	_b(b, sb, Vector3(0.85, 0.02, 0.38), Vector3(16.55, 0.82, 7.4), "glass")
	_b(b, sb, Vector3(0.35, 0.3, 0.3), Vector3(16.6, 0.15, 6.0), "linen")
	_b(b, sb, Vector3(0.04, 0.8, 0.5), Vector3(16.18, 1.4, 7.0), "linen")
	_s(b, sb, 0.05, Vector3(16.18, 1.0, 7.0), "white")
	_b(b, sb, Vector3(0.5, 1.2, 0.3), Vector3(19.75, 0.6, 5.5), "metal")
	_b(b, sb, Vector3(0.4, 0.5, 0.4), Vector3(17.6, 0.25, 4.7), "linen")


static func _up_closet(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(3.4, 0.04, 0.6), Vector3(18.0, 0.95, 0.6), "wood_light")
	_b(b, sb, Vector3(0.03, 1.0, 0.9), Vector3(16.15, 1.3, 2.4), "metal")
	_b(b, sb, Vector3(0.5, 0.9, 0.4), Vector3(19.7, 0.85, 2.0), "wood_dark")
	_b(b, sb, Vector3(0.6, 0.6, 0.6), Vector3(18.0, 0.3, 2.8), "linen")
	_b(b, sb, Vector3(0.6, 0.6, 0.6), Vector3(18.9, 0.3, 3.2), "linen")
	_b(b, sb, Vector3(0.5, 0.5, 0.5), Vector3(16.5, 0.25, 2.5), "toy")
	_b(b, sb, Vector3(0.4, 0.4, 0.4), Vector3(19.5, 0.2, 3.4), "toy")


static func _attic(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(3.0, 0.04, 0.8), Vector3(5.0, 1.3, 7.0), "wood_light")
	_b(b, sb, Vector3(1.2, 0.9, 0.5), Vector3(2.5, 0.45, 3.5), "wood_dark")
	_b(b, sb, Vector3(1.2, 0.9, 0.5), Vector3(2.5, 0.45, 4.6), "wood_dark")
	_b(b, sb, Vector3(1.2, 0.9, 0.5), Vector3(2.5, 0.45, 5.7), "wood_dark")
	_b(b, sb, Vector3(1.8, 0.55, 0.9), Vector3(8.0, 0.275, 8.0), "fabric_slate")
	_b(b, sb, Vector3(0.9, 0.5, 0.5), Vector3(9.6, 0.25, 7.5), "wood_dark")
	_b(b, sb, Vector3(0.6, 0.6, 0.6), Vector3(12.5, 0.3, 9.0), "linen")
	_b(b, sb, Vector3(0.6, 0.6, 0.6), Vector3(13.4, 0.3, 9.0), "linen")
	_b(b, sb, Vector3(0.6, 0.6, 0.6), Vector3(14.3, 0.3, 9.0), "linen")
	_c(b, sb, 0.2, 1.2, Vector3(16.5, 0.6, 6.5), "wood_dark")
	_b(b, sb, Vector3(0.5, 0.4, 0.5), Vector3(17.2, 0.2, 4.0), "toy")
	_b(b, sb, Vector3(0.5, 0.4, 0.5), Vector3(18.0, 0.2, 4.2), "toy")
	_s(b, sb, 0.18, Vector3(10.5, 0.7, 2.0), "plant")
	_b(b, sb, Vector3(0.05, 0.6, 0.8), Vector3(4.0, 1.2, 10.0), "white")
	_b(b, sb, Vector3(1.5, 0.7, 0.4), Vector3(18.5, 0.35, 11.0), "wood_light")
	_b(b, sb, Vector3(0.3, 0.4, 0.3), Vector3(18.5, 0.2, 11.5), "toy")


static func _bs_main(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(2.6, 1.7, 0.45), Vector3(2.0, 0.85, 4.5), "metal")
	for i in range(4):
		_b(b, sb, Vector3(2.55, 0.03, 0.43), Vector3(2.0, 0.4 + i * 0.4, 4.5), "wood_light")
	_b(b, sb, Vector3(2.2, 1.7, 0.45), Vector3(11.3, 0.85, 8.0), "metal_dark")
	for i in range(4):
		_b(b, sb, Vector3(2.15, 0.03, 0.43), Vector3(11.3, 0.4 + i * 0.4, 8.0), "wood_light")
	_b(b, sb, Vector3(1.4, 0.08, 0.7), Vector3(8.0, 0.84, 12.5), "wood_dark")
	_b(b, sb, Vector3(0.07, 0.76, 0.7), Vector3(7.35, 0.38, 12.5), "wood_dark")
	_b(b, sb, Vector3(0.07, 0.76, 0.7), Vector3(8.65, 0.38, 12.5), "wood_dark")
	_b(b, sb, Vector3(0.6, 0.5, 0.6), Vector3(4.0, 0.25, 11.0), "wood_light")
	_b(b, sb, Vector3(0.6, 0.5, 0.6), Vector3(4.9, 0.25, 11.0), "wood_light")
	_b(b, sb, Vector3(0.6, 0.5, 0.6), Vector3(5.8, 0.25, 11.0), "wood_light")
	_b(b, sb, Vector3(0.6, 0.5, 0.6), Vector3(6.7, 0.25, 11.0), "wood_light")
	_b(b, sb, Vector3(1.8, 0.55, 0.9), Vector3(9.5, 0.275, 13.5), "fabric_slate")
	_b(b, sb, Vector3(1.2, 0.6, 0.5), Vector3(2.5, 0.3, 13.5), "wood_dark")
	_c(b, sb, 0.05, 1.2, Vector3(5.0, -1.8, 2.0), "pipes", 90.0)
	_c(b, sb, 0.04, 1.2, Vector3(5.0, -1.8, 6.0), "pipes", 90.0)
	_c(b, sb, 0.04, 1.2, Vector3(5.0, -1.8, 10.0), "pipes", 90.0)
	_c(b, sb, 0.03, 1.4, Vector3(3.0, -1.8, 14.5), "pipes")
	_b(b, sb, Vector3(0.5, 0.5, 0.5), Vector3(7.5, 0.25, 3.0), "toy")
	_b(b, sb, Vector3(0.5, 0.5, 0.5), Vector3(8.4, 0.25, 3.0), "toy")


static func _bs_boiler(b: HouseBuilder, sb: StaticBody3D) -> void:
	_c(b, sb, 0.6, 1.9, Vector3(13.5, -2.05, 0.9), "appliance")
	_b(b, sb, Vector3(1.1, 0.06, 0.6), Vector3(13.5, -1.05, 0.9), "metal_dark")
	_c(b, sb, 0.03, 1.4, Vector3(12.7, -1.9, 2.0), "pipes")
	_c(b, sb, 0.05, 1.4, Vector3(14.3, -1.9, 2.0), "pipes")
	_c(b, sb, 0.04, 1.2, Vector3(15.6, -2.0, 1.2), "pipes", 90.0)
	_c(b, sb, 0.03, 0.8, Vector3(13.5, -1.6, 3.4), "pipes")
	_b(b, sb, Vector3(1.4, 0.04, 0.5), Vector3(13.5, -1.35, 5.0), "wood_light")
	_b(b, sb, Vector3(0.4, 0.4, 0.4), Vector3(12.5, -2.75, 6.5), "toy")
	_b(b, sb, Vector3(0.4, 0.4, 0.4), Vector3(13.4, -2.75, 6.5), "toy")


static func _bs_elec(b: HouseBuilder, sb: StaticBody3D) -> void:
	_b(b, sb, Vector3(1.6, 1.1, 0.12), Vector3(18.2, -1.6, 1.35), "appliance")
	_b(b, sb, Vector3(1.6, 0.06, 0.14), Vector3(18.2, -1.0, 1.35), "metal_dark")
	_b(b, sb, Vector3(1.1, 0.9, 0.1), Vector3(18.2, -1.8, 4.3), "appliance")
	_b(b, sb, Vector3(0.6, 0.6, 0.5), Vector3(16.5, -2.6, 5.4), "metal")
	_b(b, sb, Vector3(0.5, 0.5, 0.5), Vector3(17.5, -2.65, 5.5), "wood_light")
	_c(b, sb, 0.03, 1.2, Vector3(19.7, -2.1, 3.0), "pipes", 90.0)
	_b(b, sb, Vector3(0.8, 0.5, 0.3), Vector3(17.5, -2.7, 2.0), "toy")


static func _bs_crawl(b: HouseBuilder, sb: StaticBody3D) -> void:
	_c(b, sb, 0.05, 3.0, Vector3(16.0, -1.9, 11.0), "pipes", 90.0)
	_c(b, sb, 0.04, 3.0, Vector3(14.0, -1.9, 13.0), "pipes", 90.0)
	_c(b, sb, 0.03, 3.0, Vector3(18.0, -1.9, 13.0), "pipes", 90.0)
	_b(b, sb, Vector3(0.6, 0.4, 0.6), Vector3(15.5, -2.8, 10.5), "wood_light")
	_b(b, sb, Vector3(0.6, 0.4, 0.6), Vector3(16.5, -2.8, 10.5), "wood_light")
	_b(b, sb, Vector3(0.6, 0.4, 0.6), Vector3(17.5, -2.8, 10.5), "wood_light")
	_b(b, sb, Vector3(0.4, 0.3, 0.4), Vector3(13.5, -2.85, 14.5), "toy")
	_c(b, sb, 0.2, 0.5, Vector3(19.2, -2.75, 15.0), "car_dark")