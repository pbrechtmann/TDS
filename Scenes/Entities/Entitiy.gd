extends KinematicBody2D
class_name Entity

onready var health : Health = $Health
onready var energy_supply : EnergySupply = $EnergySupply


func _on_Health_death():
	queue_free()
