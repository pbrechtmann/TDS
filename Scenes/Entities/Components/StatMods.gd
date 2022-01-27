extends Node
class_name StatMods


var damage : float = 1.0
var speed : float = 1.0


func set_damage(to : float) -> void:
	damage = to

func reset_damage() -> void:
	damage = 1.0


func set_speed(to : float) -> void:
	speed = to

func reset_speed() -> void:
	speed = 1.0
