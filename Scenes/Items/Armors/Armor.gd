extends Node2D
class_name Armor

export var multipliers : Dictionary = {}

func modify(modifiers : Dictionary):
	modifiers = modifiers.duplicate()
	
	for key in modifiers:
		if multipliers.has(key):
			modifiers[key] = modifiers[key] * multipliers[key]
	
	return modifiers
