extends Node
class_name EnergySupply

export var max_energy : float = 100

var current_energy : float = max_energy

var charge_time : float = 10.0


func _process(delta):
	if current_energy < max_energy:
		current_energy += (max_energy / charge_time) * delta

func drain(a : float) -> bool:
	if a > current_energy:
		return false
		
	current_energy -= a
	return true


func charge(a : float) -> void:
	current_energy = clamp(current_energy + a, 0, max_energy)


func get_energy_percent() -> float:
	return clamp(inverse_lerp(0, max_energy, current_energy), 0, 1)
