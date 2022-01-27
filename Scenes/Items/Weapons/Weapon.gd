extends Node2D
class_name Weapon

onready var delay : Timer = $Timer

export(Texture) var icon

export(float) var attack_delay = 0.5
export(float, 0, 100) var attack_cost = 25

var ready : bool = true

export var modifiers : Dictionary = {}


func try_primary_attack(energy_supply, damage_mod : float) -> void:
	if ready and energy_supply.drain(attack_cost):
		primary_attack(damage_mod)
		
		ready = false
		delay.start(attack_delay)


func primary_attack(_damage_mod : float) -> void:
	pass


func _on_Timer_timeout() -> void:
	ready = true
