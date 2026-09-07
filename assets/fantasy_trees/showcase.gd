extends Node3D

var yaw := 0.12
var elevation := 0.53
var zoom := 23.0
var camera: Camera3D
const CENTER := Vector3(0, 3.5, -6.0)


func _ready() -> void:
	var manifest: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/fantasy_trees/manifest.json"))
	for i in manifest.size():
		var tree := (load("res://assets/fantasy_trees/" + manifest[i].name + ".tscn") as PackedScene).instantiate() as Node3D
		tree.position = Vector3((i % 3 - 1) * 10.5, 0, -(i / 3) * 12.0)
		tree.set("wind_offset", i * 0.53)
		add_child(tree)
		var base := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 4.5
		cylinder.bottom_radius = 4.5
		cylinder.height = 0.16
		base.mesh = cylinder
		base.position = tree.position + Vector3(0, -0.10, 0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("657c73")
		mat.roughness = 0.9
		base.material_override = mat
		add_child(base)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("444f54")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("c1cddd")
	environment.environment.ambient_light_energy = 0.65
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_color = Color("fff0d7")
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	add_child(camera)
	camera.current = true
	_update_camera()


func _update_camera() -> void:
	camera.size = zoom
	camera.position = CENTER + Vector3(sin(yaw) * cos(elevation), sin(elevation), cos(yaw) * cos(elevation)) * 40.0
	camera.look_at(CENTER)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		yaw -= event.relative.x * 0.007
		elevation = clampf(elevation + event.relative.y * 0.005, 0.15, 1.3)
		_update_camera()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = maxf(12.0, zoom - 2.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = minf(55.0, zoom + 2.0)
		_update_camera()
