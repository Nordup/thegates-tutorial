extends Node
# class_name ProgressSaver

const CONFIG_PATH := "user://progress.cfg"
const SECTION := "tutorial_progress"
const MIN_STEP := 1
const MAX_STEP := 4

signal step_completed(step: int)


func mark_step_completed(step: int) -> void:
	if step < MIN_STEP or step > MAX_STEP:
		return
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(SECTION, "step_" + str(step), true)
	var highest := 0
	if config.has_section_key(SECTION, "highest"):
		highest = int(config.get_value(SECTION, "highest"))
	if step > highest:
		config.set_value(SECTION, "highest", step)
	config.save(CONFIG_PATH)
	step_completed.emit(step)
	print("step_completed: ", step)


func is_step_completed(step: int) -> bool:
	if step < MIN_STEP or step > MAX_STEP:
		return false
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	var key := "step_" + str(step)
	if config.has_section_key(SECTION, key):
		return bool(config.get_value(SECTION, key))
	return false


func get_completed_steps() -> PackedInt32Array:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	var result := PackedInt32Array([])
	for s in range(MIN_STEP, MAX_STEP + 1):
		var key := "step_" + str(s)
		if config.has_section_key(SECTION, key) and bool(config.get_value(SECTION, key)):
			result.append(s)
	return result


func highest_completed() -> int:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	if config.has_section_key(SECTION, "highest"):
		return int(config.get_value(SECTION, "highest"))
	return 0


func mark_hint_shown(hint_id: StringName) -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(SECTION, "hint_" + str(hint_id), true)
	config.save(CONFIG_PATH)


func is_hint_shown(hint_id: StringName) -> bool:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	var key := "hint_" + str(hint_id)
	if config.has_section_key(SECTION, key):
		return bool(config.get_value(SECTION, key))
	return false


func reset_progress() -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	if config.has_section(SECTION):
		config.erase_section(SECTION)
	config.save(CONFIG_PATH)
	print("progress reset")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_progress"):
		reset_progress()
