class_name TimeWeatherController
extends Node

var day_keys: Array = []
var weather_states: Array = []
var transition_hours: float = 0.75


func configure(keys: Array, states: Array, weather_transition_hours: float) -> void:
	day_keys = keys
	weather_states = states
	transition_hours = weather_transition_hours


func sample_day(hour: float) -> Dictionary:
	var h := fposmod(hour, 24.0)
	for index in range(day_keys.size() - 1):
		var from_key: Array = day_keys[index]
		var to_key: Array = day_keys[index + 1]
		if h < from_key[0] or h > to_key[0]:
			continue
		var blend := (h - (from_key[0] as float)) / ((to_key[0] as float) - (from_key[0] as float))
		blend = blend * blend * (3.0 - 2.0 * blend)
		return {
			"elev": lerpf(from_key[1], to_key[1], blend),
			"azim": rad_to_deg(lerp_angle(deg_to_rad(from_key[2]), deg_to_rad(to_key[2]), blend)),
			"sun_color": (from_key[3] as Color).lerp(to_key[3], blend),
			"sun_energy": lerpf(from_key[4], to_key[4], blend),
			"amb_color": (from_key[5] as Color).lerp(to_key[5], blend),
			"amb_energy": lerpf(from_key[6], to_key[6], blend),
			"fog_color": (from_key[7] as Color).lerp(to_key[7], blend),
			"fog_density": lerpf(from_key[8], to_key[8], blend),
			"bg_color": (from_key[9] as Color).lerp(to_key[9], blend),
			"shadow_opacity": lerpf(from_key[10], to_key[10], blend),
		}
	return {}


func night_focus(hour: float) -> float:
	var h := fposmod(hour, 24.0)
	if h < 7.0:
		return 1.0 - smoothstep_range(5.0, 7.0, h)
	if h >= 17.5:
		return smoothstep_range(17.5, 19.5, h)
	return 0.0


func smoothstep_range(from_value: float, to_value: float, value: float) -> float:
	var blend := clampf((value - from_value) / (to_value - from_value), 0.0, 1.0)
	return blend * blend * (3.0 - 2.0 * blend)


func make_weather_schedule(seed_value: int) -> Array:
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	var schedule: Array = [{"state": "clear", "duration": random.randf_range(5.0, 8.0)}]
	var previous_state := "clear"
	for cycle: int in 3:
		var pool: Array = weather_states.duplicate()
		for index in range(pool.size() - 1, 0, -1):
			var swap_index := random.randi_range(0, index)
			var temporary: Variant = pool[index]
			pool[index] = pool[swap_index]
			pool[swap_index] = temporary
		if pool[0] == previous_state:
			var temporary: Variant = pool[0]
			pool[0] = pool[1]
			pool[1] = temporary
		for state: String in pool:
			var duration_range := weather_duration_range(state)
			schedule.append({"state": state, "duration": random.randf_range(duration_range.x, duration_range.y)})
			previous_state = state
	if schedule[-1]["state"] == schedule[0]["state"]:
		var temporary: Variant = schedule[-1]
		schedule[-1] = schedule[-2]
		schedule[-2] = temporary
	return schedule


func weather_duration_range(state: String) -> Vector2:
	match state:
		"clear": return Vector2(5.0, 8.0)
		"cloudy": return Vector2(4.0, 7.0)
		"mist": return Vector2(3.0, 5.5)
		_: return Vector2(3.0, 5.0)


func weather_profile(state: String) -> Dictionary:
	match state:
		"cloudy": return {"sun_energy": 0.78, "sun_tint": 0.20, "ambient_energy": 1.02, "ambient_tint": 0.16, "shadow": 0.78, "fog_density": 1.22, "fog_color_mix": 0.18, "background_tint": 0.20, "rain": 0.0, "wind": 0.86, "tint": Color("b5c2c1"), "fog_tint": Color("899d9f")}
		"mist": return {"sun_energy": 0.84, "sun_tint": 0.24, "ambient_energy": 1.04, "ambient_tint": 0.20, "shadow": 0.66, "fog_density": 2.0, "fog_color_mix": 0.34, "background_tint": 0.32, "rain": 0.0, "wind": 0.48, "tint": Color("b9c5bd"), "fog_tint": Color("94a8a3")}
		"light_rain": return {"sun_energy": 0.66, "sun_tint": 0.30, "ambient_energy": 1.0, "ambient_tint": 0.24, "shadow": 0.56, "fog_density": 1.48, "fog_color_mix": 0.28, "background_tint": 0.30, "rain": 1.0, "wind": 1.12, "tint": Color("aab9bb"), "fog_tint": Color("778f95")}
		_: return {"sun_energy": 1.0, "sun_tint": 0.0, "ambient_energy": 1.0, "ambient_tint": 0.0, "shadow": 1.0, "fog_density": 1.0, "fog_color_mix": 0.0, "background_tint": 0.0, "rain": 0.0, "wind": 0.62, "tint": Color.WHITE, "fog_tint": Color.WHITE}


func blend_weather_profiles(from_profile: Dictionary, to_profile: Dictionary, blend: float) -> Dictionary:
	return {
		"sun_energy": lerpf(from_profile["sun_energy"], to_profile["sun_energy"], blend), "sun_tint": lerpf(from_profile["sun_tint"], to_profile["sun_tint"], blend),
		"ambient_energy": lerpf(from_profile["ambient_energy"], to_profile["ambient_energy"], blend), "ambient_tint": lerpf(from_profile["ambient_tint"], to_profile["ambient_tint"], blend),
		"shadow": lerpf(from_profile["shadow"], to_profile["shadow"], blend), "fog_density": lerpf(from_profile["fog_density"], to_profile["fog_density"], blend),
		"fog_color_mix": lerpf(from_profile["fog_color_mix"], to_profile["fog_color_mix"], blend), "background_tint": lerpf(from_profile["background_tint"], to_profile["background_tint"], blend),
		"rain": lerpf(from_profile["rain"], to_profile["rain"], blend), "wind": lerpf(from_profile["wind"], to_profile["wind"], blend),
		"tint": (from_profile["tint"] as Color).lerp(to_profile["tint"], blend), "fog_tint": (from_profile["fog_tint"] as Color).lerp(to_profile["fog_tint"], blend),
	}
