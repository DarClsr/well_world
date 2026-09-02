extends SceneTree


func _initialize() -> void:
	var scene := load("res://scenes/main.tscn") as PackedScene
	var main := scene.instantiate()
	main.set("time_running", false)
	main.set("weather_running", false)
	main.set("weather_override", "clear")
	root.add_child(main)
	await process_frame
	for hour: float in [0.0, 9.5, 12.0, 19.5]:
		var sample: Dictionary = main.call("_sample_day", hour)
		assert(sample.has("sun_energy") and sample.has("amb_energy") and sample.has("fog_density"))
	assert((main.call("_sample_day", 12.0)["sun_energy"] as float) > (main.call("_sample_day", 0.0)["sun_energy"] as float))
	var schedule_a: Array = main.call("_make_weather_schedule", 20260902)
	var schedule_b: Array = main.call("_make_weather_schedule", 20260902)
	assert(schedule_a == schedule_b and schedule_a.size() == 13)
	assert(main.call("_weather_profile", "light_rain")["rain"] == 1.0)
	assert(main.call("_night_focus", 0.0) == 1.0)
	assert((main.get("tree_canopies") as Array).size() == 16)
	assert((main.get("pond_ripples") as Array).size() == 2)
	assert((main.get("villagers") as Array).size() == 3)
	assert(main.call("_is_house_roof_occluding", Vector2(0, 0), Vector2(0, 8), Vector2(0, 4), false))
	print("FOG VALLEY REFACTOR BASELINE PASSED")
	quit(0)
