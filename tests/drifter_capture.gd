extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	root.add_child(main)
	await create_timer(1.2).timeout
	var player := main.get_node("Player") as CharacterBody3D
	var camera := player.get_node("CameraRig/Camera3D") as Camera3D
	camera.position = Vector3(0.0, 8.0, 7.47)
	var mark := player.find_child("OtherworldMark", true, false) as MeshInstance3D
	assert(mark != null)
	print("Drifter mark offset: ", mark.global_position - player.global_position)
	await create_timer(1.0).timeout
	quit()
