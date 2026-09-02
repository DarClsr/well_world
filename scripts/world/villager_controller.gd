class_name VillagerController
extends Node


func display_name(npc_name: StringName) -> String:
	match npc_name:
		&"HerbalistMira": return "米拉"
		&"GatekeeperToren": return "托伦"
		_: return "尼娅"

