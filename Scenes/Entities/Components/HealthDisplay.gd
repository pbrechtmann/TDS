extends Node2D
class_name HealthDisplay

onready var health_bar = $HealthBar


func show_health(health : Health) -> void:
	health_bar.value = health.current_health / health.max_health * 100
