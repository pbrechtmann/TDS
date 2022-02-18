extends Node2D
class_name DamageEffect


var damage_per_second : float
var target

onready var duration_timer : Timer = $Duration


func init(target, effect_info : Dictionary) -> void:
	self.target = target
	damage_per_second = effect_info["dps"]
	
	target.health.damage(effect_info["initial_damage"])
	duration_timer.start(effect_info["duration"])


func _process(delta):
	custom_process(delta)


func custom_process(_delta : float) -> void:
	pass


func clear_effects() -> void:
	pass


func _on_Duration_timeout() -> void:
	clear_effects()
	queue_free()
