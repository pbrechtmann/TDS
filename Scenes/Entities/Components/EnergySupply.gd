extends Node
class_name EnergySupply

export var max_energy : float = 100

var current_energy : float = max_energy

signal max_changed


func regenerate(change_per_second : float, delta : float) -> void:
	current_energy = clamp(current_energy + change_per_second * delta, 0, max_energy)


func drain(a : float) -> bool:
	if a > current_energy:
		return false
		
	current_energy -= a
	return true


func charge(a : float) -> void:
	current_energy = clamp(current_energy + a, 0, max_energy)


func get_energy_percent() -> float:
	return clamp(inverse_lerp(0, max_energy, current_energy), 0, 1)


func modify_value(mod : float) -> void:
	max_energy += mod
	emit_signal("max_changed", max_energy)


func modify_percent(mod : float) -> float:
	var change : float = max_energy * (mod / 100)
	max_energy += change
	emit_signal("max_changed", max_energy)
	return change
