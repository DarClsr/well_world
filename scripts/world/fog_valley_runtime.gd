class_name FogValleyRuntime
extends Node

var host: Node


func configure(fog_valley: Node) -> void:
	assert(fog_valley != null)
	host = fog_valley


func tick(delta: float) -> void:
	if host != null and host.has_method("_runtime_tick"):
		host.call("_runtime_tick", delta)
