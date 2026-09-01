extends SceneTree


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	var player := main.get_node("Player") as CharacterBody3D
	var hearth := main.get_node("VillageHearth") as Node3D
	var hearth_audio := main.get_node("HearthFire") as AudioStreamPlayer3D
	if "--visual" in OS.get_cmdline_user_args():
		player.position = hearth.position + Vector3(3.0, 1.0, 2.4)
		await create_timer(2.0).timeout
		quit()
		return
	if "--isolated" in OS.get_cmdline_user_args():
		(main.get_node("MistValleyAmbience") as AudioStreamPlayer).volume_db = -80.0
		(main.get_node("PortalHum") as AudioStreamPlayer3D).volume_db = -80.0
	print("Hearth volume: ", hearth_audio.volume_db, " dB")
	player.position = Vector3(-12.0, 1.0, -3.8)
	print("Far distance: ", player.position.distance_to(hearth.position))
	await create_timer(2.0).timeout
	player.position = hearth.position + Vector3(0.0, 1.0, 3.0)
	print("Near distance: ", player.position.distance_to(hearth.position))
	await create_timer(3.0).timeout
	quit()
