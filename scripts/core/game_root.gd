extends Node

const FogValleyScene = preload("res://scenes/world/fog_valley.tscn")
const PrologueArrival = preload("res://data/quests/prologue_arrival.tres")

@onready var region_container: Node = $RegionContainer
@onready var scene_router: SceneRouter = $SceneRouter
@onready var quest_runtime: QuestRuntime = $QuestRuntime
@onready var dialogue_runner: DialogueRunner = $DialogueRunner
@onready var persistent_ui: CanvasLayer = $PersistentUI

var objective_row: HBoxContainer
var objective_label: Label
var objective_tween: Tween


func _ready() -> void:
	quest_runtime.configure(GameState.active, EventBus)
	quest_runtime.start_quest(PrologueArrival)
	_build_objective()
	quest_runtime.quest_advanced.connect(_on_quest_advanced)
	quest_runtime.quest_completed.connect(_on_quest_completed)
	_update_objective(false)
	GameState.state_replaced.connect(_on_state_replaced)
	dialogue_runner.event_requested.connect(_on_dialogue_event)
	scene_router.configure(region_container, GameState, EventBus)
	scene_router.register_region(&"fog_valley", FogValleyScene)
	var error := scene_router.travel_to(GameState.active.current_region, GameState.active.spawn_id)
	if error != OK:
		push_error("GameRoot: initial region load failed with error %s" % error)


func _on_dialogue_event(event_id: StringName) -> void:
	var advanced := quest_runtime.advance(&"arrival", event_id)
	if not advanced and event_id == &"mira_met":
		_update_objective()


func _on_state_replaced(state: WorldState) -> void:
	quest_runtime.configure(state, EventBus)
	quest_runtime.start_quest(PrologueArrival)
	_update_objective(false)


func _build_objective() -> void:
	objective_row = HBoxContainer.new()
	objective_row.name = "ObjectiveRow"
	objective_row.position = Vector2(42.0, 124.0)
	objective_row.size = Vector2(460.0, 24.0)
	objective_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective_row.add_theme_constant_override("separation", 9)
	persistent_ui.add_child(objective_row)

	var marker_holder := Control.new()
	marker_holder.custom_minimum_size = Vector2(11.0, 22.0)
	marker_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective_row.add_child(marker_holder)
	var marker := ColorRect.new()
	marker.name = "Marker"
	marker.position = Vector2(2.0, 7.0)
	marker.size = Vector2(7.0, 7.0)
	marker.pivot_offset = marker.size * 0.5
	marker.rotation = PI * 0.25
	marker.color = Color("59675e")
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker_holder.add_child(marker)

	objective_label = Label.new()
	objective_label.name = "ObjectiveText"
	objective_label.custom_minimum_size = Vector2(420.0, 22.0)
	objective_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	objective_label.add_theme_font_size_override("font_size", 15)
	objective_label.add_theme_color_override("font_color", Color("c9c3ae"))
	objective_label.add_theme_color_override("font_outline_color", Color(0.05, 0.07, 0.06, 0.72))
	objective_label.add_theme_constant_override("outline_size", 4)
	objective_row.add_child(objective_label)


func _update_objective(animate: bool = true) -> void:
	if objective_row == null or objective_label == null:
		return
	if objective_tween != null:
		objective_tween.kill()
	var progress: Dictionary = GameState.active.quests.get(&"arrival", {})
	if StringName(str(progress.get("status", ""))) != &"active":
		if animate and objective_row.visible:
			objective_tween = create_tween()
			objective_tween.tween_property(objective_row, "modulate:a", 0.0, 0.2)
			objective_tween.tween_callback(objective_row.hide)
		else:
			objective_row.hide()
		return
	var step_index := int(progress.get("step_index", -1))
	if step_index < 0 or step_index >= PrologueArrival.steps.size():
		objective_row.hide()
		return
	var step: QuestStepData = PrologueArrival.steps[step_index]
	objective_label.text = "替米拉采一株雾叶草" if step.id == &"gather_herb" and bool(GameState.active.flags.get(&"mira_met", false)) else tr(String(step.description_key))
	objective_row.show()
	objective_row.modulate.a = 0.35 if animate else 0.0
	objective_tween = create_tween()
	if not animate:
		objective_tween.tween_interval(2.8)
	objective_tween.tween_property(objective_row, "modulate:a", 0.78, 0.2)


func _on_quest_advanced(quest_id: StringName, _step_index: int) -> void:
	if quest_id == &"arrival":
		_update_objective()


func _on_quest_completed(quest_id: StringName) -> void:
	if quest_id == &"arrival":
		_update_objective()
