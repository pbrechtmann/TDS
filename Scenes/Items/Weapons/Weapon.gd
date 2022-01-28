extends Node2D
class_name Weapon

onready var delay : Timer = $Timer

export(Texture) var icon

export(float) var attack_delay = 0.5
export(float, 0, 100) var attack_cost = 25

export var modifiers : Dictionary = {}
var final_modifiers : Dictionary = {}

var ready : bool = true
var user : Entity


func init(user : Entity) -> void:
	self.user = user


func try_primary_attack(energy_supply, attack_mods : Dictionary) -> void:
	if ready and energy_supply.drain(attack_cost):
		primary_attack(attack_mods)
		
		ready = false
		delay.start(attack_delay)


func primary_attack(attack_mods : Dictionary) -> void:
	pass


func create_final_mods(attack_mods : Dictionary) -> Dictionary:
	var final_mods = modifiers.duplicate()
	if final_mods.has("damage"):
		final_mods["damage"] *= attack_mods["damage"]
	if final_mods.has("lifesteal"):
		final_mods["lifesteal"] += attack_mods["lifesteal"]
	elif attack_mods["lifesteal"] > 0:
		final_mods["lifesteal"] = attack_mods["lifesteal"]
	
	return final_mods


func _on_Timer_timeout() -> void:
	ready = true
