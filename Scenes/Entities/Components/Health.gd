extends Node
class_name Health

export var max_health : float = 100
var current_health : float 

signal death
signal max_changed


func _ready():
	current_health = max_health


func damage(a : float):
	current_health -= a
	if current_health <= 0:
		emit_signal("death")


func heal(a : float):
	current_health = clamp(current_health + a, 0, max_health)


func modify_value(mod : float) -> void:
	max_health += mod
	emit_signal("max_changed", max_health)


func modify_percent(mod : float) -> float:
	var change : float = max_health * (mod / 100)
	max_health += change
	emit_signal("max_changed", max_health)
	return change
