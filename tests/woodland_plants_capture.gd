extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1440, 1000)
	root.content_scale_size = Vector2i(1440, 1000)
	var stage := Node3D.new()
	root.add_child(stage)
	var entries: Array = JSON.parse_string(FileAccess.get_file_as_string("res://assets/fantasy_props/manifest.json"))
	var nature := "--nature" in OS.get_cmdline_user_args()
	var travel := "--travel" in OS.get_cmdline_user_args()
	var village := "--village" in OS.get_cmdline_user_args()
	var category := "travel" if travel else ("nature" if nature else "plants")
	var prefix := "travel" if travel else ("nature" if nature else "woodland")
	var columns := 2 if travel else (3 if nature else 4)
	if village:
		category = "village"
		prefix = "village"
		columns = 3
	entries = entries.filter(func(entry: Dictionary) -> bool: return entry.category == category)
	for i in entries.size():
		var model := (load("res://assets/fantasy_props/" + entries[i].name + ".tscn") as PackedScene).instantiate() as Node3D
		model.position = Vector3((i % columns - (columns - 1) * 0.5) * 2.6, 0, -(i / columns) * 2.8)
		stage.add_child(model)
		var tile := MeshInstance3D.new()
		var cube := BoxMesh.new()
		cube.size = Vector3(2.35, 0.08, 2.20)
		tile.mesh = cube
		tile.position = model.position + Vector3(0, -0.06, 0)
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("667677")
		mat.roughness = 0.9
		tile.material_override = mat
		stage.add_child(tile)
		var label := Label3D.new()
		label.text = String(entries[i].name).left(2)
		label.font_size = 40
		label.pixel_size = 0.005
		label.position = model.position + Vector3(-0.92, 0.03, 0.89)
		label.rotation_degrees.x = -90
		stage.add_child(label)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("414c50")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("c9d8dd")
	env.environment.ambient_light_energy = 0.28
	stage.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -25, 0)
	sun.light_color = Color("fff0d8")
	sun.light_energy = 0.65
	sun.shadow_enabled = true
	stage.add_child(sun)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.9 if travel else (7.0 if nature or village else 8.0)
	stage.add_child(camera)
	camera.position = Vector3(2.6, 8.5, 10)
	camera.look_at(Vector3(0, 0.1, -1.3))
	camera.current = true
	await create_timer(0.6).timeout
	var players := stage.find_children("*", "AnimationPlayer", true, false)
	assert(players.size() == (1 if travel else (0 if nature or village else 4)))
	for player: AnimationPlayer in players:
		if travel:
			player.play(player.get_animation_list()[0])
		player.pause()
	DirAccess.make_dir_recursive_absolute("res://temp/" + prefix + "-plants-motion")
	for frame in range(1 if nature or village else 64):
		for i in players.size():
			(players[i] as AnimationPlayer).seek(fposmod(frame / 16.0 + i * 0.41, 4.0), true)
		await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		image.save_png("res://temp/" + prefix + "-plants-motion/frame_%03d.png" % frame)
		if frame == 0:
			image.save_png("res://art/fantasy_props/" + prefix + "_godot.png")
	camera.position = Vector3(-4, 5, -10)
	camera.look_at(Vector3(0, 0.1, -1.3))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://art/fantasy_props/" + prefix + "_reverse.png")
	if village:
		camera.size = 1.5
		for i in entries.size():
			var center := Vector3((i % columns - (columns - 1) * 0.5) * 2.6, 0.38, -(i / columns) * 2.8)
			camera.position = center + Vector3(1.4, 1.3, 2.1)
			camera.look_at(center)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://art/fantasy_props/village_detail_" + String(entries[i].name).left(2) + ".png")
	print("CATEGORY_CAPTURE_PASS ", category, " reverse=true")
	quit()
