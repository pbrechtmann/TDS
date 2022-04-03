extends Node2D
class_name Armor

export var base_multipliers : Dictionary = {
	"damage": 1,
	"cold": {
		"damage": 1,
		"duration": 1
		},
	"fire": {
		"dps": 1,
		"duration": 1
		},
	"poison": {
		"dps": 1,
		"duration": 1
		}
	}

export var dmg_resistance_amount : int = 0
export var cold_resistance_amount : int = 0
export var fire_resistance_amount : int = 0
export var poison_resistance_amount : int = 0

var multipliers : Dictionary

func _ready() -> void:
	multipliers = base_multipliers.duplicate(true)


func modify(modifiers : Dictionary) -> Dictionary:
	modifiers = modifiers.duplicate(true)
	
	for key in modifiers:
		if multipliers.has(key):
			match key:
				"damage":
					modifiers[key] *= multipliers[key]
				"bleeding":
					pass
				"cold":
					modifiers[key]["initial_damage"] *= multipliers[key]["damage"]
					modifiers[key]["duration"] *= multipliers[key]["duration"]
				"fire":
					modifiers[key]["dps"] *= multipliers[key]["dps"]
					modifiers[key]["duration"] *= multipliers[key]["duration"]
				"poison":
					modifiers[key]["dps"] *= multipliers[key]["dps"]
					modifiers[key]["duration"] *= multipliers[key]["duration"]
	
	return modifiers
