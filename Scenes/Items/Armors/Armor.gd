extends Node2D
class_name Armor

export var multipliers : Dictionary = {}

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
