extends Node3D
## Plays authored foliage wind; no blocking collision or physical contact response.

@export_range(0.1, 2.0) var wind_speed := 1.0


func _ready() -> void:
	var player := find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player:
		for clip in player.get_animation_list():
			if clip != "RESET":
				player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
				player.speed_scale = wind_speed
				player.play(clip)
				player.seek(fposmod(global_position.x * 0.31 + global_position.z * 0.19, 4.0), true)
				break
