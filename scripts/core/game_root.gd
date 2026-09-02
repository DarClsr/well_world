extends Node

const FogValleyScene = preload("res://scenes/world/fog_valley.tscn")
const PrologueArrival = preload("res://data/quests/prologue_arrival.tres")

@onready var region_container: Node = $RegionContainer
@onready var scene_router: SceneRouter = $SceneRouter
@onready var quest_runtime: QuestRuntime = $QuestRuntime
@onready var dialogue_runner: DialogueRunner = $DialogueRunner


func _ready() -> void:
	quest_runtime.configure(GameState.active, EventBus)
	quest_runtime.start_quest(PrologueArrival)
	GameState.state_replaced.connect(_on_state_replaced)
	dialogue_runner.event_requested.connect(_on_dialogue_event)
	scene_router.configure(region_container, GameState, EventBus)
	scene_router.register_region(&"fog_valley", FogValleyScene)
	var error := scene_router.travel_to(GameState.active.current_region, GameState.active.spawn_id)
	if error != OK:
		push_error("GameRoot: initial region load failed with error %s" % error)


func _on_dialogue_event(event_id: StringName) -> void:
	quest_runtime.advance(&"arrival", event_id)


func _on_state_replaced(state: WorldState) -> void:
	quest_runtime.configure(state, EventBus)
	quest_runtime.register_quest(PrologueArrival)
