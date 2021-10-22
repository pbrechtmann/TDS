extends Node
class_name Health

export var max_health : float = 100
var current_health : float 

signal death


func _ready():
	current_health = max_health
	if connect("death", get_parent(), "_on_Health_death") != OK:
		printerr("Connecting death signal to character ", get_parent().name, " failed.")


func damage(a : float):
	current_health -= a
	if current_health <= 0:
		emit_signal("death")


func heal(a : float):
	current_health = clamp(current_health + a, 0, max_health)
