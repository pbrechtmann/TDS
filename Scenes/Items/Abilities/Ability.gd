extends Node2D
class_name Ability

export(float) var ability_cost = 25
export(float) var ability_delay = 2

var ready : bool = true

onready var cooldown_timer : Timer = $Cooldown


func try_activate_ability(user : Entity) -> void:
	if ready and user.energy_supply.drain(ability_cost):
		activate_ability(user)
		ready = false
		cooldown_timer.start(ability_delay)


func activate_ability(_user : Entity) -> void:
	pass


func _on_Cooldown_timeout():
	ready = true
