extends Node

const FogValleyScene = preload("res://scenes/world/fog_valley.tscn")
const PrologueArrival = preload("res://data/quests/prologue_arrival.tres")

@onready var region_container: Node = $RegionContainer
@onready var scene_router: SceneRouter = $SceneRouter
@onready var quest_runtime: QuestRuntime = $QuestRuntime


func _ready() -> void:
	quest_runtime.configure(GameState.active, EventBus)
	quest_runtime.start_quest(PrologueArrival)
	scene_router.configure(region_container, GameState, EventBus)
	scene_router.register_region(&"fog_valley", FogValleyScene)
	var error := scene_router.travel_to(GameState.active.current_region, GameState.active.spawn_id)
	if error != OK:
		push_error("GameRoot: initial region load failed with error %s" % error)
