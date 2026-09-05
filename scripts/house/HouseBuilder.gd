class_name HouseBuilder
## Procedurally builds the entire FakeUni house.
## Deterministic: every peer builds the identical house locally, so nothing
## needs to be network-synced. All static geometry.

const WALL_T := 0.18
const DOOR_H := 2.1
const SILL_H := 0.9
const HEAD_H := 2.05

# ---- floor level config ---------------------------------------------------
const G_FLOOR := 0.0      # ground floor walk surface
const S_FLOOR := 3.2      # second floor walk surface
const A_FLOOR := 6.4      # attic walk surface
const B_FLOOR := -3.0     # basement walk surface
const SLAB_T := 0.25

const G_H := 2.95         # ground room wall height
const S_H := 2.95         # second floor room wall height
const B_H := 2.45         # basement room wall height
const A_H := 2.2          # attic wall height
const CRAWL_H := 1.9      # crawlspace height

const GROUND_FOOTPRINT := Rect2(0, 0, 20, 16)
const SECOND_FOOTPRINT := Rect2(0, 0, 20, 16)
const BASEMENT_FOOTPRINT := Rect2(0, 0, 20, 16)
const ATTIC_FOOTPRINT := Rect2(0, 0, 20, 16)

const HOUSE_X_MAX := 28.0   # includes garage
const HOUSE_Z_MIN := -3.0   # includes pantry bump-out

# room: [x, z, w, d, floor, h, style]
const ROOMS := [
	# ---- ground floor -------------------------------------------------
	["foyer",    9.0, 12.0, 4.0, 4.0, 0, G_H, "foyer"],
	["living",  13.0,  8.0, 7.0, 8.0, 0, G_H, "living"],
	["den",      0.0, 10.0, 9.0, 6.0, 0, G_H, "den"],
	["hallway",  8.0,  7.0, 5.0, 5.0, 0, G_H, "hallway"],
	["dining",   0.0,  5.0, 8.0, 5.0, 0, G_H, "dining"],
	["kitchen",  8.0,  0.0, 8.0, 7.0, 0, G_H, "kitchen"],
	["pantry",  13.5, -3.0, 2.5, 3.0, 0, G_H, "pantry"],
	["bathroom",16.0,  0.0, 4.0, 4.0, 0, G_H, "bathroom"],
	["laundry",  5.0,  0.0, 3.0, 4.0, 0, G_H, "laundry"],
	["utility",  0.0,  0.0, 5.0, 5.0, 0, G_H, "utility"],
	["mudroom", 16.0,  4.0, 4.0, 4.0, 0, G_H, "mudroom"],
	["garage",  20.0,  0.0, 8.0, 12.0, 0, G_H, "garage"],
	# ---- second floor -------------------------------------------------
	["up_hallway", 8.0,  8.0, 5.0, 8.0, 1, S_H, "hallway"],
	["master",    13.0,  8.0, 7.0, 8.0, 1, S_H, "bedroom"],
	["bedroom2",   0.0,  8.0, 8.0, 8.0, 1, S_H, "bedroom"],
	["bedroom3",   0.0,  0.0, 8.0, 8.0, 1, S_H, "bedroom"],
	["office",     8.0,  0.0, 8.0, 8.0, 1, S_H, "office"],
	["up_bathroom",16.0, 4.0, 4.0, 4.0, 1, S_H, "bathroom"],
	["up_closet", 16.0,  0.0, 4.0, 4.0, 1, S_H, "closet"],
	# ---- basement -----------------------------------------------------
	["bs_stairwell", 0.0,  0.6,  1.4,  3.8, 2, B_H, "basement"],
	["bs_main",  1.4,  0.0, 10.6, 16.0, 2, B_H, "basement"],
	["bs_boiler",12.0, 0.0,  4.0,  8.0, 2, B_H, "basement"],
	["bs_elec", 16.0,  0.0,  4.0,  6.0, 2, B_H, "basement"],
	["bs_crawl",12.0,  8.0,  8.0,  8.0, 2, CRAWL_H, "crawl"],
	# ---- attic ---------------------------------------------------------
	["attic",   0.0,  0.0, 20.0, 16.0, 3, A_H, "attic"],
]

const DOORS := [
	["foyer", "hallway"], ["foyer", "living"], ["foyer", "den"],
	["hallway", "living"], ["hallway", "dining"],
	["dining", "den"], ["dining", "kitchen"],
	["kitchen", "pantry"], ["kitchen", "laundry"], ["kitchen", "bathroom"],
	["kitchen", "mudroom"], ["laundry", "utility"], ["mudroom", "garage"],
	["up_hallway", "bedroom2"], ["up_hallway", "master"], ["up_hallway", "office"],
	["bedroom2", "bedroom3"], ["bedroom3", "office"],
	["office", "up_bathroom"], ["master", "up_bathroom"], ["up_bathroom", "up_closet"],
	["bs_main", "bs_boiler"], ["bs_main", "bs_crawl"], ["bs_boiler", "bs_elec"],
]

# door center offsets (m, along the shared edge) to keep doors clear of stairs
const DOOR_OFFSETS := {
	"foyer|hallway": -1.0,
	"hallway|living": -0.8,
}

# exterior doors: [room, side, a, b]
const EXTERIOR_DOORS := [
	["foyer", "s", 10.2, 11.8],
	["kitchen", "n", 11.0, 12.5],
	["garage", "e", 4.0, 8.0],
]

# windows: [room, side, a, b]
const WINDOWS := [
	["foyer", "s", 12.3, 13.0],
	["living", "e", 9.5, 11.1], ["living", "e", 12.9, 14.5],
	["living", "s", 14.5, 16.1], ["living", "s", 17.9, 19.5],
	["den", "w", 11.0, 12.6], ["den", "w", 13.4, 15.0],
	["den", "s", 2.0, 3.6], ["den", "s", 5.4, 7.0],
	["dining", "w", 6.0, 7.6],
	["kitchen", "n", 9.0, 10.6], ["kitchen", "n", 13.0, 14.6],
	["laundry", "n", 5.8, 7.2],
	["utility", "w", 1.5, 3.0],
	["bathroom", "n", 16.8, 18.4],
	["garage", "e", 9.0, 10.6], ["garage", "n", 21.0, 22.6], ["garage", "s", 25.0, 26.6],
	["pantry", "n", 14.0, 15.5], ["pantry", "e", -2.0, -1.0],
	["master", "s", 14.0, 15.6], ["master", "s", 17.4, 19.0],
	["master", "e", 10.0, 11.6], ["master", "e", 12.4, 14.0],
	["bedroom2", "w", 10.0, 11.6], ["bedroom2", "s", 2.0, 3.6], ["bedroom2", "s", 4.4, 6.0],
	["bedroom3", "w", 2.0, 3.6], ["bedroom3", "w", 4.4, 6.0],
	["office", "n", 10.0, 11.6], ["office", "n", 12.4, 14.0],
	["up_bathroom", "n", 17.0, 18.6],
	["up_hallway", "s", 9.0, 10.6],
]

# interior lights: [room, x, z, energy, color, height offset]
const LIGHTS := [
	["foyer", 11.0, 14.0, 0.9, "fff1d8", 2.6],
	["living", 16.5, 12.0, 1.0, "fff0d0", 2.6],
	["den", 4.5, 13.0, 0.8, "ffe9c8", 2.6],
	["dining", 4.0, 7.5, 0.85, "fff0d0", 2.6],
	["kitchen", 12.0, 3.5, 1.0, "fdf6ff", 2.6],
	["hallway", 10.5, 9.5, 0.7, "fff0d0", 2.6],
	["up_hallway", 10.5, 12.0, 0.7, "fff0d0", 2.8],
	["master", 16.5, 12.0, 0.8, "ffe9c8", 2.8],
	["bedroom2", 4.0, 12.0, 0.8, "ffe9c8", 2.8],
	["bedroom3", 4.0, 4.0, 0.8, "ffe9c8", 2.8],
	["office", 12.0, 4.0, 0.8, "fdf6ff", 2.8],
	["up_bathroom", 18.0, 6.0, 0.8, "fdf6ff", 2.8],
	["bs_main", 6.0, 8.0, 0.75, "ffe9b0", 2.0],
	["bs_boiler", 14.0, 4.0, 0.7, "ffd8a0", 2.0],
	["garage", 24.0, 6.0, 0.8, "fff0d0", 2.6],
]

var _mats := {}
var _unit_box: BoxMesh
var _unit_sphere: SphereMesh
var _unit_cyl: CylinderMesh
var _unit_quad: QuadMesh

var _rooms := {}   # name -> rect+config
var _house: Node3D


func build(parent: Node3D) -> void:
	_house = parent
	_make_shared()
	_register_rooms()
	_build_structure()
	_build_rooms()
	_build_stairs()
	_build_exterior()
	_build_yard()
	_build_lights()
	FurnitureFactory.populate(self, _house)


# ------------------------------------------------------------------ helpers

func _make_shared() -> void:
	_unit_box = BoxMesh.new()
	_unit_box.size = Vector3.ONE
	_unit_sphere = SphereMesh.new()
	_unit_sphere.radius = 0.5
	_unit_sphere.height = 1.0
	_unit_cyl = CylinderMesh.new()
	_unit_cyl.top_radius = 0.5
	_unit_cyl.bottom_radius = 0.5
	_unit_cyl.height = 1.0
	_unit_quad = QuadMesh.new()
	_unit_quad.size = Vector2.ONE


func _register_rooms() -> void:
	for r in ROOMS:
		_rooms[r[0]] = {
			"rect": Rect2(r[1], r[2], r[3], r[4]),
			"floor": r[5],
			"h": r[6],
			"style": r[7],
		}


func _floor_y(floor: int) -> float:
	match floor:
		0: return G_FLOOR
		1: return S_FLOOR
		2: return B_FLOOR
		3: return A_FLOOR
	return 0.0


func _room_floor_y(name: String) -> float:
	return _floor_y(_rooms[name]["floor"])


func room_rect(name: String) -> Rect2:
	return _rooms[name]["rect"]


func room_floor_y(name: String) -> float:
	return _room_floor_y(name)


func room_height(name: String) -> float:
	return _rooms[name]["h"]


func unit_box() -> BoxMesh:
	return _unit_box


func unit_sphere() -> SphereMesh:
	return _unit_sphere


func unit_cyl() -> CylinderMesh:
	return _unit_cyl


func unit_quad() -> QuadMesh:
	return _unit_quad


func mat(key: String) -> StandardMaterial3D:
	if not _mats.has(key):
		_mats[key] = _make_mat(key)
	return _mats[key]


func _make_mat(key: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.roughness = 0.9
	m.albedo_color = Color("c9bdaa")
	match key:
		"plaster": m.albedo_color = Color("f2ead8"); m.roughness = 0.95
		"plaster_dim": m.albedo_color = Color("cfc6b2")
		"siding": m.albedo_color = Color("b9a88a"); m.roughness = 1.0
		"brick": m.albedo_color = Color("9c4a3a")
		"wood_light": m.albedo_color = Color("c89a62"); m.roughness = 0.7
		"wood_dark": m.albedo_color = Color("7a5230"); m.roughness = 0.75
		"wood_plank": m.albedo_color = Color("a87d4f"); m.roughness = 0.8
		"tile": m.albedo_color = Color("d8d4cc"); m.roughness = 0.35
		"tile_dark": m.albedo_color = Color("6a6a70"); m.roughness = 0.4
		"carpet": m.albedo_color = Color("9a8f7a"); m.roughness = 1.0
		"carpet_blue": m.albedo_color = Color("5a7290"); m.roughness = 1.0
		"carpet_red": m.albedo_color = Color("8a3f38"); m.roughness = 1.0
		"concrete": m.albedo_color = Color("8d8d8a"); m.roughness = 0.95
		"concrete_dark": m.albedo_color = Color("5d5d5a")
		"glass": m.albedo_color = Color(0.75, 0.88, 1.0, 0.35); m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; m.roughness = 0.05
		"metal": m.albedo_color = Color("b8b8c0"); m.roughness = 0.35; m.metallic = 0.6
		"metal_dark": m.albedo_color = Color("5f5f66"); m.roughness = 0.4; m.metallic = 0.7
		"frame": m.albedo_color = Color("4a3a28"); m.roughness = 0.6
		"white": m.albedo_color = Color("f4f2ec"); m.roughness = 0.7
		"door_wood": m.albedo_color = Color("8a5f35"); m.roughness = 0.55
		"roof": m.albedo_color = Color("5a4a3e"); m.roughness = 1.0
		"grass": m.albedo_color = Color("5f8f4a"); m.roughness = 1.0
		"path": m.albedo_color = Color("a8a297"); m.roughness = 0.9
		"stone": m.albedo_color = Color("9a9488"); m.roughness = 0.85
		"plant": m.albedo_color = Color("3f7a3a"); m.roughness = 1.0
		"counter": m.albedo_color = Color("d9d3c8"); m.roughness = 0.4
		"appliance": m.albedo_color = Color("d5d5da"); m.roughness = 0.35
		"fabric_red": m.albedo_color = Color("a03a32"); m.roughness = 1.0
		"fabric_teal": m.albedo_color = Color("3f7f80"); m.roughness = 1.0
		"fabric_gold": m.albedo_color = Color("c9a14f"); m.roughness = 1.0
		"fabric_slate": m.albedo_color = Color("5f6a78"); m.roughness = 1.0
		"linen": m.albedo_color = Color("e6ded2"); m.roughness = 0.95
		"skin": m.albedo_color = Color("e8c39a"); m.roughness = 0.7
		"toy": m.albedo_color = Color("e05a4a"); m.roughness = 0.7
		"pipes": m.albedo_color = Color("9aa0a8"); m.roughness = 0.4
		"car_red": m.albedo_color = Color("a83a30"); m.roughness = 0.4; m.metallic = 0.5
		"car_dark": m.albedo_color = Color("2e2e34"); m.roughness = 0.4
	return m


## Add a solid box: visual mesh + collision, under a StaticBody3D parent.
func box(parent: Node, size: Vector3, pos: Vector3, mat_key: String, rot_deg: float = 0.0, body: StaticBody3D = null) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _unit_box
	mi.material_override = mat(mat_key)
	mi.position = pos
	mi.scale = size
	if rot_deg != 0.0:
		mi.rotate_y(deg_to_rad(rot_deg))
	parent.add_child(mi)
	_add_collision(body if body != null else parent, size, pos, rot_deg)


## Visual-only quad/plane (no collision).
func flat(parent: Node, size: Vector2, pos: Vector3, mat_key: String, rot_deg: float = 0.0, face: Vector3 = Vector3.UP) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _unit_quad
	mi.material_override = mat(mat_key)
	mi.position = pos
	mi.scale = Vector3(size.x, 1.0, size.y)
	mi.rotate_object_local(face, 0.0)
	if face == Vector3.UP:
		mi.rotate_x(-PI / 2.0)
	elif face == Vector3.FORWARD:
		pass
	if rot_deg != 0.0:
		mi.rotate_y(deg_to_rad(rot_deg))
	parent.add_child(mi)


func mesh_box(parent: Node, size: Vector3, pos: Vector3, mat_key: String, rot_deg: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _unit_box
	mi.material_override = mat(mat_key)
	mi.position = pos
	mi.scale = size
	if rot_deg != 0.0:
		mi.rotate_y(deg_to_rad(rot_deg))
	parent.add_child(mi)


func mesh_sphere(parent: Node, radius: float, pos: Vector3, mat_key: String) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _unit_sphere
	mi.material_override = mat(mat_key)
	mi.position = pos
	mi.scale = Vector3.ONE * (radius * 2.0)
	parent.add_child(mi)


func mesh_cyl(parent: Node, radius: float, height: float, pos: Vector3, mat_key: String, rot_deg_x: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = _unit_cyl
	mi.material_override = mat(mat_key)
	mi.position = pos
	mi.scale = Vector3(radius * 2.0, height, radius * 2.0)
	if rot_deg_x != 0.0:
		mi.rotate_x(deg_to_rad(rot_deg_x))
	parent.add_child(mi)


func _add_collision(body: Node, size: Vector3, pos: Vector3, rot_deg: float = 0.0) -> void:
	if body is StaticBody3D:
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		cs.shape = shape
		cs.position = pos
		if rot_deg != 0.0:
			cs.rotate_y(deg_to_rad(rot_deg))
		body.add_child(cs)
		return
	# fallback: standalone static body
	var sb := StaticBody3D.new()
	sb.position = pos
	var cs2 := CollisionShape3D.new()
	var shape2 := BoxShape3D.new()
	shape2.size = size
	cs2.shape = shape2
	if rot_deg != 0.0:
		cs2.rotate_y(deg_to_rad(rot_deg))
	sb.add_child(cs2)
	body.add_child(sb)


func new_room_body(name: String, floor: int) -> StaticBody3D:
	var sb := StaticBody3D.new()
	sb.name = name
	sb.collision_layer = 1
	sb.collision_mask = 0
	_house.add_child(sb)
	return sb


# ------------------------------------------------------------------ structure

func _build_structure() -> void:
	# Structural floor slabs (top surface = walk surface of each floor).
	# The ground slab has a rectangular hole where the basement stairs go down.
	_big_slab(Vector3(HOUSE_X_MAX / 2.0 - 0.0, G_FLOOR - SLAB_T / 2.0, (16.0 + HOUSE_Z_MIN) / 2.0),
		Vector2(HOUSE_X_MAX, 16.0 - HOUSE_Z_MIN), "concrete_dark", Rect2(0.0, 0.6, 1.4, 3.8))
	_big_slab(Vector3(SECOND_FOOTPRINT.get_center().x, S_FLOOR - SLAB_T / 2.0, SECOND_FOOTPRINT.get_center().y),
		Vector2(SECOND_FOOTPRINT.size.x, SECOND_FOOTPRINT.size.y), "concrete_dark")
	_big_slab(Vector3(ATTIC_FOOTPRINT.get_center().x, A_FLOOR - SLAB_T / 2.0, ATTIC_FOOTPRINT.get_center().y),
		Vector2(ATTIC_FOOTPRINT.size.x, ATTIC_FOOTPRINT.size.y), "wood_plank", Rect2(9.0, 14.5, 2.0, 1.5))
	_big_slab(Vector3(BASEMENT_FOOTPRINT.get_center().x, B_FLOOR - SLAB_T / 2.0, BASEMENT_FOOTPRINT.get_center().y),
		Vector2(BASEMENT_FOOTPRINT.size.x, BASEMENT_FOOTPRINT.size.y), "concrete_dark")

	# Basement + attic get their own low ceiling slabs.
	_ceil_slab("bs_main", B_H)
	_ceil_slab("bs_boiler", B_H)
	_ceil_slab("bs_elec", B_H)
	_ceil_slab("bs_crawl", CRAWL_H)

	# Foundation wall around basement (so the dirt doesn't show).
	_foundation_walls()


func _big_slab(center: Vector3, footprint: Vector2, mat_key: String, hole: Rect2 = Rect2()) -> void:
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	_house.add_child(sb)
	if hole.size == Vector2.ZERO:
		box(sb, Vector3(footprint.x, SLAB_T, footprint.y), center, mat_key, 0.0, sb)
		return
	# slab with a rectangular hole (attic hatch): build 4 rects around the hole
	var r := Rect2(center.x - footprint.x / 2.0, center.z - footprint.y / 2.0, footprint.x, footprint.y)
	var h2 := Rect2(hole.position.x, hole.position.y, hole.size.x, hole.size.y)
	# bottom strip
	_add_slab_rect(sb, Rect2(r.position.x, r.position.y, r.size.x, h2.position.y - r.position.y), center.y, mat_key, sb)
	# top strip
	var h_top := r.end.y - (h2.end.y)
	_add_slab_rect(sb, Rect2(r.position.x, h2.end.y, r.size.x, h_top), center.y, mat_key, sb)
	# left
	_add_slab_rect(sb, Rect2(r.position.x, h2.position.y, h2.position.x - r.position.x, h2.size.y), center.y, mat_key, sb)
	# right
	_add_slab_rect(sb, Rect2(h2.end.x, h2.position.y, r.end.x - h2.end.x, h2.size.y), center.y, mat_key, sb)


func _add_slab_rect(sb: StaticBody3D, r: Rect2, y: float, mat_key: String, body: StaticBody3D) -> void:
	if r.size.x < 0.001 or r.size.y < 0.001:
		return
	box(sb, Vector3(r.size.x, SLAB_T, r.size.y), Vector3(r.get_center().x, y, r.get_center().y), mat_key, 0.0, body)


func _ceil_slab(room: String, h: float) -> void:
	var r: Rect2 = _rooms[room]["rect"]
	var fy := _floor_y(_rooms[room]["floor"])
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	_house.add_child(sb)
	box(sb, Vector3(r.size.x + 2.0 * WALL_T, SLAB_T, r.size.y + 2.0 * WALL_T),
		Vector3(r.get_center().x, fy + h + SLAB_T / 2.0, r.get_center().y), "concrete_dark", 0.0, sb)


func _foundation_walls() -> void:
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	_house.add_child(sb)
	var t := 0.3
	var r := BASEMENT_FOOTPRINT
	var top := B_FLOOR
	var bottom := B_FLOOR - 0.4
	var hgt := top - bottom
	# four sides
	box(sb, Vector3(r.size.x + 2 * t, hgt, t), Vector3(r.get_center().x, bottom + hgt / 2.0, r.position.y), "concrete", 0.0, sb)
	box(sb, Vector3(r.size.x + 2 * t, hgt, t), Vector3(r.get_center().x, bottom + hgt / 2.0, r.end.y), "concrete", 0.0, sb)
	box(sb, Vector3(t, hgt, r.size.y), Vector3(r.position.x, bottom + hgt / 2.0, r.get_center().y), "concrete", 0.0, sb)
	box(sb, Vector3(t, hgt, r.size.y), Vector3(r.end.x, bottom + hgt / 2.0, r.get_center().y), "concrete", 0.0, sb)


# ------------------------------------------------------------------ rooms

func _build_rooms() -> void:
	var door_map := {}
	for pair in DOORS:
		door_map[_key(pair[0], pair[1])] = true

	for r in ROOMS:
		var name: String = r[0]
		var rect: Rect2 = Rect2(r[1], r[2], r[3], r[4])
		var floor: int = r[5]
		var h: float = r[6]
		var fy := _floor_y(floor)
		var sb := new_room_body(name, floor)

		# floor finish
		var finish := _floor_finish(r[7])
		flat(sb, Vector2(rect.size.x - 0.02, rect.size.y - 0.02),
			Vector3(rect.get_center().x, fy + 0.015, rect.get_center().y), finish)

		# four walls
		var walls := [
			["n", Vector2(rect.position.x, rect.position.y), Vector2(rect.end.x, rect.position.y)],
			["s", Vector2(rect.position.x, rect.end.y), Vector2(rect.end.x, rect.end.y)],
			["w", Vector2(rect.position.x, rect.position.y), Vector2(rect.position.x, rect.end.y)],
			["e", Vector2(rect.end.x, rect.position.y), Vector2(rect.end.x, rect.end.y)],
		]
		for w in walls:
			var side: String = w[0]
			var a: Vector2 = w[1]
			var b: Vector2 = w[2]
			var openings := _openings_for(name, side, rect, door_map)
			_build_wall(sb, a, b, fy, h, side_is_exterior(name, side, rect), openings)


func _key(a: String, b: String) -> String:
	if a < b:
		return a + "|" + b
	return b + "|" + a


func _floor_finish(style: String) -> String:
	match style:
		"kitchen", "pantry", "bathroom", "laundry", "utility", "mudroom":
			return "tile"
		"garage", "basement", "crawl":
			return "concrete"
		"attic":
			return "wood_plank"
		"bedroom", "master", "living", "den", "dining", "hallway", "office", "foyer":
			return "wood_light"
		_:
			return "wood_light"


func side_is_exterior(name: String, side: String, rect: Rect2) -> bool:
	for other in _rooms:
		if other == name:
			continue
		if _rooms[name]["floor"] != _rooms[other]["floor"]:
			continue
		var sh := _shared_edge(rect, _rooms[other]["rect"])
		if not sh.is_empty() and sh[0] == side:
			return false
	return true


func _openings_for(name: String, side: String, rect: Rect2, door_map: Dictionary) -> Array:
	var openings := []
	var door_list := []
	# interior doors (from DOORS adjacency): door centered on shared edge
	for other in _rooms:
		if other == name:
			continue
		if not door_map.has(_key(name, other)):
			continue
		var orr: Rect2 = _rooms[other]["rect"]
		if _rooms[name]["floor"] != _rooms[other]["floor"]:
			continue
		var shared := _shared_edge(rect, orr)
		if shared.is_empty() or shared[0] != side:
			continue
		var c: float = (shared[1] + shared[2]) / 2.0
		var key := _key(name, other)
		if DOOR_OFFSETS.has(key):
			c += DOOR_OFFSETS[key]
		var w: float = 1.1
		door_list.append([maxf(c - w / 2.0, shared[1]), minf(c + w / 2.0, shared[2])])
	# exterior doors are always carved too (a wall can have both)
	for d in _exterior_door_for(name, side, rect):
		door_list.append(d)
	for d in door_list:
		openings.append({ "type": "door", "a": d[0], "b": d[1] })
	if side_is_exterior(name, side, rect):
		for w in _windows_for(name, side, rect):
			openings.append({ "type": "window", "a": w[0], "b": w[1] })
	return openings


func _shared_edge(a: Rect2, b: Rect2) -> Array:
	# returns [side_of_a, along_lo, along_hi] if they share an edge
	var sides := [
		["n", a.position.y, b.end.y, "s"],
		["s", a.end.y, b.position.y, "n"],
		["w", a.position.x, b.end.x, "e"],
		["e", a.end.x, b.position.x, "w"],
	]
	for s in sides:
		var side: String = s[0]
		var edge: float = s[1]
		var other_edge: float = s[2]
		if absf(edge - other_edge) < 0.01:
			var lo: float
			var hi: float
			if side == "n" or side == "s":
				lo = maxf(a.position.x, b.position.x)
				hi = minf(a.end.x, b.end.x)
			else:
				lo = maxf(a.position.y, b.position.y)
				hi = minf(a.end.y, b.end.y)
			if hi - lo > 0.5:
				return [side, lo, hi]
	return []


func _exterior_door_for(name: String, side: String, rect: Rect2) -> Array:
	for d in EXTERIOR_DOORS:
		if d[0] != name or d[1] != side:
			continue
		return [[d[2], d[3]]]
	return []


func _windows_for(name: String, side: String, rect: Rect2) -> Array:
	var out := []
	for w in WINDOWS:
		if w[0] != name or w[1] != side:
			continue
		out.append([w[2], w[3]])
	return out


func _build_wall(sb: StaticBody3D, a: Vector2, b: Vector2, fy: float, h: float, exterior: bool, openings: Array) -> void:
	var mat_key := "siding" if exterior else "plaster"
	var horizontal := absf(a.y - b.y) < 0.001
	var len := a.distance_to(b)
	if len < 0.05:
		return
	var lo := (a.x if horizontal else a.y)
	var hi := (b.x if horizontal else b.y)
	if lo > hi:
		var tmp := lo; lo = hi; hi = tmp

	# gather openings sorted
	var spans := [{ "lo": lo, "hi": hi }]
	for o in openings:
		var o_lo: float = o["a"]
		var o_hi: float = o["b"]
		if o_lo > o_hi:
			var t2 := o_lo; o_lo = o_hi; o_hi = t2
		var cut := []
		for sp in spans:
			if o_lo >= sp["hi"] or o_hi <= sp["lo"]:
				cut.append(sp)
				continue
			if o_lo > sp["lo"]:
				cut.append({ "lo": sp["lo"], "hi": o_lo })
			if o_hi < sp["hi"]:
				cut.append({ "lo": o_hi, "hi": sp["hi"] })
		spans = cut

	for sp in spans:
		var slen: float = sp["hi"] - sp["lo"]
		if slen < 0.01:
			continue
		var mid: float = (sp["lo"] + sp["hi"]) / 2.0
		var pos: Vector3
		if horizontal:
			pos = Vector3(mid, fy + h / 2.0, a.y)
		else:
			pos = Vector3(a.x, fy + h / 2.0, mid)
		var size := Vector3(slen, h, WALL_T) if horizontal else Vector3(WALL_T, h, slen)
		box(sb, size, pos, mat_key, 0.0, sb)

	# door leaves + window frames/glass
	for o in openings:
		if o["type"] == "window":
			_build_window(sb, a, b, fy, h, exterior, o["a"], o["b"])
		else:
			_build_door(sb, a, b, fy, h, exterior, o["a"], o["b"])


func _wall_dir(a: Vector2, b: Vector2) -> Vector2:
	return (b - a).normalized()


func _build_window(sb: StaticBody3D, a: Vector2, b: Vector2, fy: float, h: float, exterior: bool, o_lo: float, o_hi: float) -> void:
	var horizontal := absf(a.y - b.y) < 0.001
	var dir := _wall_dir(a, b)
	var mid := (o_lo + o_hi) / 2.0
	var wlen := o_hi - o_lo
	var frame_mat := "frame"
	var glass_mat := "glass"
	# lower wall (sill to floor)
	if horizontal:
		box(sb, Vector3(wlen, SILL_H, WALL_T), Vector3(mid, fy + SILL_H / 2.0, a.y), "plaster", 0.0, sb)
		# upper wall (header to ceiling)
		var uh := h - HEAD_H
		if uh > 0.05:
			box(sb, Vector3(wlen, uh, WALL_T), Vector3(mid, fy + HEAD_H + uh / 2.0, a.y), "plaster", 0.0, sb)
		# glass
		box(sb, Vector3(wlen - 0.12, HEAD_H - SILL_H - 0.08, 0.05), Vector3(mid, fy + SILL_H + (HEAD_H - SILL_H) / 2.0, a.y + dir.y * WALL_T * 0.35), glass_mat, 0.0, sb)
		# frame
		box(sb, Vector3(0.07, HEAD_H - SILL_H, WALL_T + 0.02), Vector3(o_lo + 0.035, fy + SILL_H + (HEAD_H - SILL_H) / 2.0, a.y), frame_mat, 0.0, sb)
		box(sb, Vector3(0.07, HEAD_H - SILL_H, WALL_T + 0.02), Vector3(o_hi - 0.035, fy + SILL_H + (HEAD_H - SILL_H) / 2.0, a.y), frame_mat, 0.0, sb)
	else:
		box(sb, Vector3(WALL_T, SILL_H, wlen), Vector3(a.x, fy + SILL_H / 2.0, mid), "plaster", 0.0, sb)
		var uh := h - HEAD_H
		if uh > 0.05:
			box(sb, Vector3(WALL_T, uh, wlen), Vector3(a.x, fy + HEAD_H + uh / 2.0, mid), "plaster", 0.0, sb)
		box(sb, Vector3(0.05, HEAD_H - SILL_H - 0.08, wlen - 0.12), Vector3(a.x + dir.x * WALL_T * 0.35, fy + SILL_H + (HEAD_H - SILL_H) / 2.0, mid), glass_mat, 0.0, sb)
		box(sb, Vector3(WALL_T + 0.02, HEAD_H - SILL_H, 0.07), Vector3(a.x, fy + SILL_H + (HEAD_H - SILL_H) / 2.0, o_lo + 0.035), frame_mat, 0.0, sb)
		box(sb, Vector3(WALL_T + 0.02, HEAD_H - SILL_H, 0.07), Vector3(a.x, fy + SILL_H + (HEAD_H - SILL_H) / 2.0, o_hi - 0.035), frame_mat, 0.0, sb)


func _build_door(sb: StaticBody3D, a: Vector2, b: Vector2, fy: float, h: float, exterior: bool, o_lo: float, o_hi: float) -> void:
	var horizontal := absf(a.y - b.y) < 0.001
	var mid := (o_lo + o_hi) / 2.0
	var dw := o_hi - o_lo
	# upper wall above door
	var uh := h - DOOR_H
	if uh > 0.05:
		if horizontal:
			box(sb, Vector3(dw, uh, WALL_T), Vector3(mid, fy + DOOR_H + uh / 2.0, a.y), "plaster", 0.0, sb)
		else:
			box(sb, Vector3(WALL_T, uh, dw), Vector3(a.x, fy + DOOR_H + uh / 2.0, mid), "plaster", 0.0, sb)
	# door frame
	if horizontal:
		box(sb, Vector3(0.05, DOOR_H, WALL_T + 0.04), Vector3(o_lo + 0.025, fy + DOOR_H / 2.0, a.y), "frame", 0.0, sb)
		box(sb, Vector3(0.05, DOOR_H, WALL_T + 0.04), Vector3(o_hi - 0.025, fy + DOOR_H / 2.0, a.y), "frame", 0.0, sb)
		box(sb, Vector3(dw + 0.05, 0.05, WALL_T + 0.04), Vector3(mid, fy + DOOR_H, a.y), "frame", 0.0, sb)
	else:
		box(sb, Vector3(WALL_T + 0.04, DOOR_H, 0.05), Vector3(a.x, fy + DOOR_H / 2.0, o_lo + 0.025), "frame", 0.0, sb)
		box(sb, Vector3(WALL_T + 0.04, DOOR_H, 0.05), Vector3(a.x, fy + DOOR_H / 2.0, o_hi - 0.025), "frame", 0.0, sb)
		box(sb, Vector3(WALL_T + 0.04, 0.05, dw + 0.05), Vector3(a.x, fy + DOOR_H, mid), "frame", 0.0, sb)
	# door leaf swung open AGAINST the wall beside the opening (gap stays clear)
	var leaf := 0.05
	var leaf_h := DOOR_H - 0.04
	if horizontal:
		box(sb, Vector3(dw, leaf_h, leaf), Vector3(o_lo - dw / 2.0 + 0.02, fy + leaf_h / 2.0, a.y + WALL_T / 2.0 + 0.03), "door_wood", 0.0, sb)
	else:
		box(sb, Vector3(leaf, leaf_h, dw), Vector3(a.x + WALL_T / 2.0 + 0.03, fy + leaf_h / 2.0, o_lo - dw / 2.0 + 0.02), "door_wood", 0.0, sb)


# ------------------------------------------------------------------ stairs

func _build_stairs() -> void:
	# Ground -> second: in the hallway, x11.5..12.5, from z12 (bottom) to z8 (top)
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	_house.add_child(sb)
	_stair_flight(sb, Vector3(11.5, 0.0, 12.0), Vector3(11.5, S_FLOOR, 8.0), 1.0, 16, true)
	# under-stair storage enclosure (the south/low end)
	_under_stair_storage(sb)

	# Basement stairs: in utility x0.4..1.4, from z4.4 down to z0.6
	var sb2 := StaticBody3D.new()
	sb2.collision_layer = 1
	sb2.collision_mask = 0
	_house.add_child(sb2)
	_stair_flight_down(sb2, Vector3(0.5, 0.0, 4.4), Vector3(0.5, -3.0, 0.6), 1.0, 15)
	# basement stair enclosure walls
	_enclosed_stairwell(sb2)

	# Attic ladder in up_hallway, at hatch x9..11, z14.5..16
	var sb3 := StaticBody3D.new()
	sb3.collision_layer = 1
	sb3.collision_mask = 0
	_house.add_child(sb3)
	_attic_ladder(sb3)


func _stair_flight(sb: StaticBody3D, from: Vector3, to: Vector3, width: float, steps: int, railing: bool) -> void:
	var rise := (to.y - from.y) / float(steps)
	var run_vec := Vector3(to.x - from.x, 0.0, to.z - from.z) / float(steps)
	for i in steps:
		var t := float(i)
		var pos := from + run_vec * t
		pos.y = from.y + rise * (t + 1.0)
		var step_size := Vector3(width, rise, run_vec.length())
		box(sb, step_size, pos + Vector3(0, -rise / 2.0, 0), "wood_light", 0.0, sb)
		# riser
		var riser_pos := pos - run_vec.normalized() * (run_vec.length() / 2.0)
		riser_pos.y = from.y + rise * (t + 0.5)
		box(sb, Vector3(width, rise, 0.05), riser_pos, "wood_dark", 0.0, sb)
	# stringers (sides)
	var h1 := to.y - from.y
	var hlen := absf(from.z - to.z) + absf(from.x - to.x)
	box(sb, Vector3(0.08, h1 + 0.2, hlen + 0.2),
		Vector3(from.x - width / 2.0 - 0.04, from.y + h1 / 2.0, (from.z + to.z) / 2.0), "wood_dark", 0.0, sb)
	box(sb, Vector3(0.08, h1 + 0.2, hlen + 0.2),
		Vector3(from.x + width / 2.0 + 0.04, from.y + h1 / 2.0, (from.z + to.z) / 2.0), "wood_dark", 0.0, sb)
	if railing:
		# railing on the east side (x12.5) at ~0.9 height
		box(sb, Vector3(0.05, 0.9, hlen), Vector3(from.x + width / 2.0 + 0.09, from.y + 0.9, (from.z + to.z) / 2.0), "frame", 0.0, sb)
		# railing on west side along the upper portion
		box(sb, Vector3(0.05, 0.9, hlen * 0.5), Vector3(from.x - width / 2.0 - 0.09, from.y + 0.9, to.z + (from.z - to.z) * 0.25), "frame", 0.0, sb)


func _stair_flight_down(sb: StaticBody3D, from: Vector3, to: Vector3, width: float, steps: int) -> void:
	var rise := (to.y - from.y) / float(steps)
	var run_vec := Vector3(to.x - from.x, 0.0, to.z - from.z) / float(steps)
	for i in steps:
		var t := float(i)
		var pos := from + run_vec * t
		pos.y = from.y + rise * (t + 1.0)
		box(sb, Vector3(width, -rise, run_vec.length()), pos + Vector3(0, rise / 2.0, 0), "concrete", 0.0, sb)
		var riser_pos := pos - run_vec.normalized() * (run_vec.length() / 2.0)
		riser_pos.y = from.y + rise * (t + 0.5)
		box(sb, Vector3(width, -rise, 0.05), riser_pos, "concrete_dark", 0.0, sb)


func _under_stair_storage(sb: StaticBody3D) -> void:
	# A little storage nook under the low end of the main staircase.
	box(sb, Vector3(0.8, 0.35, 0.7), Vector3(12.0, 0.175, 11.62), "wood_light", 0.0, sb)
	box(sb, Vector3(0.75, 0.7, 0.05), Vector3(12.0, 0.35, 11.99), "door_wood", 0.0, sb)
	box(sb, Vector3(0.04, 0.7, 0.75), Vector3(11.63, 0.35, 11.65), "frame", 0.0, sb)
	box(sb, Vector3(0.04, 0.7, 0.75), Vector3(12.37, 0.35, 11.65), "frame", 0.0, sb)


func _enclosed_stairwell(sb: StaticBody3D) -> void:
	# parapet walls around the basement stair opening on the ground floor
	box(sb, Vector3(0.1, 1.0, 4.0), Vector3(-0.06, 0.5, 2.5), "plaster", 0.0, sb)
	box(sb, Vector3(0.1, 1.0, 4.0), Vector3(1.46, 0.5, 2.5), "plaster", 0.0, sb)
	# half-height rail on the entry side (z4.4) with a gap for the stairs
	box(sb, Vector3(0.9, 0.95, 0.06), Vector3(0.36, 0.475, 4.38), "frame", 0.0, sb)
	box(sb, Vector3(0.5, 0.95, 0.06), Vector3(1.22, 0.475, 4.38), "frame", 0.0, sb)


func _attic_ladder(sb: StaticBody3D) -> void:
	# vertical ladder from up_hallway (y3.2) up to attic floor (y6.4) through hatch
	var x := 10.0
	var z := 15.2
	var hgt := A_FLOOR - S_FLOOR
	# ladder rails
	box(sb, Vector3(0.05, hgt, 0.05), Vector3(x - 0.2, S_FLOOR + hgt / 2.0, z), "metal", 0.0, sb)
	box(sb, Vector3(0.05, hgt, 0.05), Vector3(x + 0.2, S_FLOOR + hgt / 2.0, z), "metal", 0.0, sb)
	for i in range(12):
		var yy := S_FLOOR + 0.5 + i * 0.42
		box(sb, Vector3(0.45, 0.04, 0.06), Vector3(x, yy, z), "metal", 0.0, sb)


# ------------------------------------------------------------------ exterior

func _build_exterior() -> void:
	# Roof over the whole house (simple gable-ish: flat slab at ceiling level with slope).
	_build_roof()

	# Porch at the front door
	var porch := StaticBody3D.new()
	porch.collision_layer = 1
	porch.collision_mask = 0
	_house.add_child(porch)
	box(porch, Vector3(2.6, 0.15, 2.0), Vector3(11.0, 0.075, 16.6), "stone", 0.0, porch)
	# front steps
	for i in range(3):
		box(porch, Vector3(1.8 - i * 0.4, 0.15, 0.5), Vector3(11.0, 0.075 + 0.15 * i, 17.7 + i * 0.5), "stone", 0.0, porch)

	# Back patio slab
	var patio := StaticBody3D.new()
	patio.collision_layer = 1
	patio.collision_mask = 0
	_house.add_child(patio)
	box(patio, Vector3(5.0, 0.12, 3.0), Vector3(11.75, -0.06, -1.7), "stone", 0.0, patio)


func _build_roof() -> void:
	# Flat roof slab over the whole footprint + garage, at ceiling height.
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	_house.add_child(sb)
	# main block roof above second floor (attic ceiling top)
	var roof_y := A_FLOOR + A_H + SLAB_T / 2.0
	box(sb, Vector3(20.0 + 1.0, SLAB_T, 16.0 + 1.0), Vector3(10.0, roof_y, 8.0), "roof", 0.0, sb)
	# garage roof
	box(sb, Vector3(8.0 + 0.6, SLAB_T, 12.0 + 0.6), Vector3(24.0, G_FLOOR + G_H + SLAB_T / 2.0, 6.0), "roof", 0.0, sb)
	# pantry roof
	box(sb, Vector3(2.5 + 0.4, SLAB_T, 3.0 + 0.4), Vector3(14.75, G_FLOOR + G_H + SLAB_T / 2.0, -1.5), "roof", 0.0, sb)
	# small gable above the attic hatch area? skip for now


func _build_yard() -> void:
	# Ground plane (grass) covering the yard around the house
	var sb := StaticBody3D.new()
	sb.collision_layer = 1
	sb.collision_mask = 0
	_house.add_child(sb)
	box(sb, Vector3(80.0, 0.2, 80.0), Vector3(-6.0, -0.1, 6.0), "grass", 0.0, sb)

	# fence around the yard
	var fz := StaticBody3D.new()
	fz.collision_layer = 1
	fz.collision_mask = 0
	_house.add_child(fz)
	_fence(fz, Vector3(-14.0, 0.0, -12.0), Vector3(34.0, 0.0, -12.0))
	_fence(fz, Vector3(-14.0, 0.0, -12.0), Vector3(-14.0, 0.0, 22.0))
	_fence(fz, Vector3(34.0, 0.0, -12.0), Vector3(34.0, 0.0, 22.0))
	_fence(fz, Vector3(-14.0, 0.0, 22.0), Vector3(11.0, 0.0, 22.0))
	_fence(fz, Vector3(13.0, 0.0, 22.0), Vector3(34.0, 0.0, 22.0))
	# gate gap between x11..13 on the front

	# garden planters / bushes near the back
	var gar := StaticBody3D.new()
	gar.collision_layer = 1
	gar.collision_mask = 0
	_house.add_child(gar)
	for i in range(6):
		var gx := 3.0 + i * 2.2
		mesh_sphere(gar, 0.5, Vector3(gx, 0.35, -4.0), "plant")
		mesh_cyl(gar, 0.18, 0.5, Vector3(gx, 0.25, -4.0), "plant")


func _fence(parent: Node, a: Vector3, b: Vector3) -> void:
	var len := a.distance_to(b)
	var dir := (b - a).normalized()
	var mid := (a + b) / 2.0
	var hgt := 1.2
	var along_x := absf(a.z - b.z) < 0.01
	var post_gap := 2.0
	var posts := int(floorf(len / post_gap)) + 1
	var off := (len - (posts - 1) * post_gap) / 2.0
	for i in range(posts):
		var p := a + dir * (off + i * post_gap)
		box(parent, Vector3(0.08, hgt, 0.08), p + Vector3(0, hgt / 2.0, 0), "frame", 0.0, parent)
	if along_x:
		box(parent, Vector3(len, 0.9, 0.05), mid + Vector3(0, 0.45, 0), "frame", 0.0, parent)
		box(parent, Vector3(len, 0.6, 0.05), mid + Vector3(0, 1.05, 0), "frame", 0.0, parent)
	else:
		box(parent, Vector3(0.05, 0.9, len), mid + Vector3(0, 0.45, 0), "frame", 0.0, parent)
		box(parent, Vector3(0.05, 0.6, len), mid + Vector3(0, 1.05, 0), "frame", 0.0, parent)


func _build_lights() -> void:
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, -40.0, 0.0)
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	sun.shadow_blur = 2.0
	_house.add_child(sun)

	for l in LIGHTS:
		var omni := OmniLight3D.new()
		omni.position = Vector3(l[1], _floor_y(_rooms[l[0]]["floor"]) + l[5], l[2])
		omni.light_energy = l[3]
		omni.omni_range = 7.0
		omni.light_color = Color(l[4])
		omni.shadow_enabled = false
		_house.add_child(omni)

	# ceiling lamp fixtures (visual)
	for l in LIGHTS:
		var r: Rect2 = _rooms[l[0]]["rect"]
		var fy := _floor_y(_rooms[l[0]]["floor"])
		var h: float = _rooms[l[0]]["h"]
		mesh_sphere(_house, 0.08, Vector3(l[1], fy + h - 0.05, l[2]), "white")
		mesh_cyl(_house, 0.012, 0.3, Vector3(l[1], fy + h - 0.15, l[2]), "metal_dark")
