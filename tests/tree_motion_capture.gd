extends SceneTree


const FRAME_RATE := 30.0
const TOTAL_FRAMES := 180


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var output_dir := "res://temp/tree-motion"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	(main.get_node("Opening") as CanvasLayer).visible = false
	var player := main.get_node("Player") as CharacterBody3D
	var camera_rig := player.get_node("CameraRig") as Node3D
	player.set_physics_process(false)
	player.position = Vector3(-17.0, 1.0, -17.0)
	player.camera_yaw = 0.0
	player.camera_target_height = 10.0
	camera_rig.rotation.y = player.camera_yaw
	player.call("_update_camera_zoom", 1.0)
	await create_timer(1.0).timeout
	main.set_process(false)

	var canopies: Array = main.get("tree_canopies")
	var canopy_materials: Array = main.get("tree_canopy_materials")
	var meadow_material := (main.get_node("MeadowGrass") as MultiMeshInstance3D).material_override as ShaderMaterial
	var falling_leaves := main.get("falling_leaves") as Node3D
	assert(canopies.size() == 16 and canopy_materials.size() == 16)
	assert(falling_leaves.get_child_count() == 12)
	var tree_transforms: Array[Transform3D] = []
	for canopy in canopies:
		tree_transforms.append((canopy as MeshInstance3D).global_transform)
	var leaf_start: Array[Vector3] = []
	for leaf in falling_leaves.get_children():
		leaf_start.append((leaf as MeshInstance3D).position)

	for frame_index in TOTAL_FRAMES:
		main.set("weather_override", "clear" if frame_index < 120 else "light_rain")
		main.set("portal_time", 1.0 + float(frame_index) / FRAME_RATE)
		main.call("_apply_time_of_day")
		main.call("_animate_tree_canopies")
		main.call("_animate_falling_leaves")
		await process_frame
		if DisplayServer.get_name() != "headless" and frame_index in [0, 119, 179]:
			var shot_name := "clear-start" if frame_index == 0 else ("clear-end" if frame_index == 119 else "rain-end")
			var image := root.get_texture().get_image()
			image.save_png(ProjectSettings.globalize_path("%s/%s.png" % [output_dir, shot_name]))
			print("SAVED ", shot_name)

	for index in canopies.size():
		assert((canopies[index] as MeshInstance3D).global_transform.is_equal_approx(tree_transforms[index]))
	assert(is_equal_approx((canopy_materials[0] as ShaderMaterial).get_shader_parameter("wind_strength"), 1.12))
	assert(is_equal_approx(meadow_material.get_shader_parameter("wind_strength"), 1.12))
	assert(is_equal_approx(meadow_material.get_shader_parameter("motion_time"), 6.9666665), "Meadow motion time should track deterministic capture time")
	var moved_leaves := 0
	for index in falling_leaves.get_child_count():
		if not (falling_leaves.get_child(index) as MeshInstance3D).position.is_equal_approx(leaf_start[index]):
			moved_leaves += 1
	assert(moved_leaves == 12)
	for player_mesh_node in player.get_node("Visual").find_children("*", "MeshInstance3D", true, false):
		(player_mesh_node as MeshInstance3D).material_overlay = null
	main.free()
	print("TREE MOTION TEST PASSED canopies=", canopies.size(), " leaves=", moved_leaves)
	quit()
