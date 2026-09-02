extends Node

signal save_failed(path: String, reason: String)


func save_state(state: WorldState, path: String) -> Error:
	if state == null or not path.begins_with("user://"):
		return _fail(path, "Save state is null or path is outside user://.", ERR_INVALID_PARAMETER)
	var absolute_path := ProjectSettings.globalize_path(path)
	var directory := absolute_path.get_base_dir()
	var directory_error := DirAccess.make_dir_recursive_absolute(directory)
	if directory_error != OK:
		return _fail(path, "Could not create save directory.", directory_error)
	var temporary_path := absolute_path + ".tmp"
	var backup_path := absolute_path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _fail(path, "Could not open temporary save file.", FileAccess.get_open_error())
	file.store_string(JSON.stringify(state.to_dictionary(), "\t"))
	file.flush()
	file.close()
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	var had_previous := FileAccess.file_exists(absolute_path)
	if had_previous:
		var backup_error := DirAccess.rename_absolute(absolute_path, backup_path)
		if backup_error != OK:
			DirAccess.remove_absolute(temporary_path)
			return _fail(path, "Could not rotate previous save.", backup_error)
	var replace_error := DirAccess.rename_absolute(temporary_path, absolute_path)
	if replace_error != OK:
		if had_previous and FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, absolute_path)
		return _fail(path, "Could not activate temporary save.", replace_error)
	return OK


func load_state(path: String) -> WorldState:
	var state := _read_state(path)
	if state != null:
		return state
	return _read_state(path + ".bak")


func has_valid_save(path: String) -> bool:
	return _read_state(path) != null


func _read_state(path: String) -> WorldState:
	if not path.begins_with("user://") or not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return null
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return null
	return WorldState.from_dictionary(parsed as Dictionary)


func _fail(path: String, reason: String, error: Error) -> Error:
	push_error("SaveService: %s (%s)" % [reason, path])
	save_failed.emit(path, reason)
	return error
