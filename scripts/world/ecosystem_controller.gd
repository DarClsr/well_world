class_name EcosystemController
extends Node


func butterfly_alpha(hour: float) -> float:
	var h := fposmod(hour, 24.0)
	return _smoothstep(7.0, 8.0, h) * (1.0 - _smoothstep(18.0, 19.0, h))


func firefly_alpha(hour: float) -> float:
	var h := fposmod(hour, 24.0)
	return maxf(_smoothstep(19.5, 20.5, h), 1.0 - _smoothstep(4.5, 5.5, h))


func _smoothstep(from_value: float, to_value: float, value: float) -> float:
	var blend := clampf((value - from_value) / (to_value - from_value), 0.0, 1.0)
	return blend * blend * (3.0 - 2.0 * blend)
