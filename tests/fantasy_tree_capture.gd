extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1280, 900)
	root.content_scale_size = Vector2i(1280, 900)
	var showcase := (load("res://assets/fantasy_trees/showcase.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(showcase)
	var hero := "--hero" in OS.get_cmdline_user_args()
	if hero:
		var main_tree := showcase.get_child(0) as Node3D
		for child in showcase.get_children():
			if child is Node3D and child != main_tree and not child is Camera3D and not child is Light3D and not child is WorldEnvironment:
				child.visible = false
		var camera := showcase.get("camera") as Camera3D
		camera.size = 10.5
		camera.position = main_tree.position + Vector3(10, 7.5, 13)
		camera.look_at(main_tree.position + Vector3(0, 3.9, 0))
	await create_timer(1.0).timeout
	var players := showcase.find_children("*", "AnimationPlayer", true, false)
	assert(players.size() == 6)
	for player: AnimationPlayer in players:
		player.pause()
	var output := "res://temp/fantasy-tree-hero" if hero else "res://temp/fantasy-tree-motion"
	DirAccess.make_dir_recursive_absolute(output)
	for frame in range(96):
		for i in players.size():
			(players[i] as AnimationPlayer).seek(fposmod(frame / 24.0 + i * 0.53, 4.0), true)
		await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		assert(not image.is_empty())
		image.save_png(output + "/frame_%03d.png" % frame)
		if frame == 0:
			image.save_png("res://art/fantasy_trees/godot_hero.png" if hero else "res://art/fantasy_trees/godot_preview.png")
	if hero:
		print("TREE_HERO_CAPTURE_PASS frames=96 falling_leaves=true")
		quit()
		return
	showcase.set("yaw", 2.3)
	showcase.call("_update_camera")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://art/fantasy_trees/godot_reverse.png")
	print("TREE_CAPTURE_PASS frames=96 reverse_view=true")
	quit()
