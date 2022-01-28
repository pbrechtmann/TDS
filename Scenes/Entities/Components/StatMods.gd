extends Node
class_name StatMods


var damage : float = 1.0
var speed : float = 1.0

var attack_mods : Dictionary = {"damage" : 1.0,
								"lifesteal" : 0.0
								}

func set_damage(to : float) -> void:
	attack_mods["damage"] = to

func reset_damage() -> void:
	attack_mods["damage"] = 1.0


func set_lifesteal(to : float) -> void:
	attack_mods["lifesteal"] = to

func reset_lifesteal() -> void:
	attack_mods["lifesteal"] = 0.0


func set_speed(to : float) -> void:
	speed = to

func reset_speed() -> void:
	speed = 1.0
