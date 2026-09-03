extends SceneTree

const SaveServiceScript = preload("res://scripts/save/save_service.gd")

const SAVE_PATH := "user://tests/phase0-save.json"


func _initialize() -> void:
	_cleanup()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://tests"))
	var service = SaveServiceScript.new()
	root.add_child(service)
	assert(not service.has_valid_save(SAVE_PATH))
	var first := WorldState.new()
	first.flags[&"cycle"] = 1
	assert(service.save_state(first, SAVE_PATH) == OK)
	assert(service.has_valid_save(SAVE_PATH))
	var loaded: WorldState = service.load_state(SAVE_PATH)
	assert(loaded != null and loaded.flags[&"cycle"] == 1)
	var second := WorldState.new()
	second.flags[&"cycle"] = 2
	assert(service.save_state(second, SAVE_PATH) == OK)
	assert(FileAccess.file_exists(SAVE_PATH + ".bak"))
	var corrupt := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	corrupt.store_string(JSON.stringify({"version": 1, "flags": null}))
	corrupt.close()
	loaded = service.load_state(SAVE_PATH)
	assert(loaded != null and loaded.flags[&"cycle"] == 1)
	corrupt = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	corrupt.store_string("{broken")
	corrupt.close()
	loaded = service.load_state(SAVE_PATH)
	assert(loaded != null and loaded.flags[&"cycle"] == 1)
	assert(service.load_state("user://tests/missing.json") == null)
	_cleanup()
	print("SAVE SERVICE TEST PASSED")
	quit(0)


func _cleanup() -> void:
	for suffix: String in ["", ".tmp", ".bak"]:
		var path := SAVE_PATH + suffix
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
