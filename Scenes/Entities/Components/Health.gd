extends Node
class_name Health

export var max_health : float = 100
var current_health : float 

var invincible : bool = false


signal death
signal max_changed


func _ready() -> void:
	current_health = max_health


func regenerate(change_per_second : float, delta : float) -> void:
	current_health = clamp(current_health + change_per_second * delta, 0, max_health)


func damage(a : float) -> void:
	if invincible: 
		return
	current_health -= a
	if current_health <= 0:
		emit_signal("death")


func heal(a : float) -> void:
	current_health = clamp(current_health + a, 0, max_health)


func modify_value(mod : float) -> void:
	max_health += mod
	emit_signal("max_changed", max_health)


func modify_percent(mod : float) -> float:
	var change : float = max_health * (mod / 100)
	max_health += change
	emit_signal("max_changed", max_health)
	return change
