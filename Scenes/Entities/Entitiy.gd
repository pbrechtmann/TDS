extends KinematicBody2D
class_name Entity

onready var health : Health = $Health
onready var energy_supply : EnergySupply = $EnergySupply
<<<<<<< Updated upstream
=======
onready var energy_display : EnergyDisplay = $EnergyDisplay


func _process(_delta):
	health_display.show_health(health)
	energy_display.show_energy(energy_supply)
>>>>>>> Stashed changes


func _on_Health_death():
	queue_free()
