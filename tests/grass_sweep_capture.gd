extends SceneTree


const SHOTS := [
	# [name, player_position, yaw_degrees, camera_height]
	["01-portal-near", Vector3(10.0, 1.0, 14.0), 0.0, 10.0],
	["02-portal-far", Vector3(10.0, 1.0, 14.0), 0.0, 20.0],
	["03-portal-west", Vector3(5.5, 1.0, 11.0), 90.0, 12.0],
	["04-pond-fork", Vector3(-3.5, 1.0, 11.0), 0.0, 12.0],
	["05-pond-close", Vector3(-9.0, 1.0, 13.5), -35.0, 10.0],
	["06-road-mid-north", Vector3(1.5, 1.0, 4.0), 0.0, 12.0],
	["07-road-mid-south", Vector3(1.5, 1.0, 4.0), 180.0, 12.0],
	["08-village-north", Vector3(0.0, 1.0, -4.0), 0.0, 12.0],
	["09-village-east", Vector3(0.0, 1.0, -4.0), 90.0, 12.0],
	["10-village-south", Vector3(0.0, 1.0, -4.0), 180.0, 12.0],
	["11-village-west", Vector3(0.0, 1.0, -4.0), 270.0, 12.0],
	["12-village-far", Vector3(0.0, 1.0, -4.0), 0.0, 20.0],
	["13-hearth-close", Vector3(4.2, 1.0, -5.8), 15.0, 10.0],
	["14-herb-yard", Vector3(-5.0, 1.0, -8.2), 205.0, 10.0],
	["15-west-house", Vector3(-4.5, 1.0, -2.5), 240.0, 12.0],
	["16-north-road", Vector3(2.5, 1.0, -9.0), 0.0, 12.0],
	["17-mist-pass", Vector3(0.0, 1.0, -20.5), 0.0, 12.0],
	["18-corner-ne", Vector3(17.0, 1.0, -17.0), 45.0, 15.0],
	["19-corner-nw", Vector3(-17.0, 1.0, -17.0), -45.0, 15.0],
	["20-corner-se", Vector3(17.0, 1.0, 9.0), 135.0, 15.0],
	["21-corner-sw", Vector3(-17.0, 1.0, 9.0), -135.0, 15.0],
]


func _initialize() -> void:
	call_deferred("_record")


func _record() -> void:
	var rain_capture := "--rain" in OS.get_cmdline_user_args()
	var output_dir := "res://temp/grass-sweep-rain" if rain_capture else "res://temp/grass-sweep"
	DirAccess.make_dir_recursive_absolute(output_dir)
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_hour", 9.5)
	main.set("time_running", false)
	main.set("weather_seed", 20260902)
	main.set("weather_running", false)
	main.set("weather_override", "light_rain" if rain_capture else "clear")
	root.add_child(main)
	await create_timer(1.5).timeout
	var player := main.get_node("Player") as CharacterBody3D
	for shot in SHOTS:
		player.position = shot[1]
		player.camera_yaw = deg_to_rad(shot[2])
		player.camera_target_height = shot[3]
		await create_timer(1.2).timeout
		await process_frame
		await process_frame
		var image := root.get_texture().get_image()
		var path := "%s/%s.png" % [output_dir, shot[0]]
		image.save_png(ProjectSettings.globalize_path(path))
		print("SAVED ", shot[0])
	quit()
