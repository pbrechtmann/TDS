extends Node2D
class_name Armor

export var multipliers : Dictionary = {
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


func modify(modifiers : Dictionary) -> Dictionary:
	modifiers = modifiers.duplicate()
	
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


func upgrade_base_resistance() -> void:
	dmg_resistance_amount += 1
	multipliers["damage"] = pow(0.95, dmg_resistance_amount)

func upgrade_cold_resistance() -> void:
	cold_resistance_amount += 1
	multipliers["cold"]["damage"] = pow(0.95, cold_resistance_amount)
	multipliers["cold"]["duration"] = pow(0.95, cold_resistance_amount)

func upgrade_fire_resistance() -> void:
	fire_resistance_amount += 1
	multipliers["fire"]["dps"] = pow(0.95, fire_resistance_amount)
	multipliers["fire"]["duration"] = pow(0.95, fire_resistance_amount)

func upgrade_poison_resistance() -> void:
	poison_resistance_amount += 1
	multipliers["poison"]["dps"] = pow(0.95, poison_resistance_amount)
	multipliers["poison"]["duration"] = pow(0.95, poison_resistance_amount)
