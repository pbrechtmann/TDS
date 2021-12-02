extends Area2D
class_name LevelExit

onready var sprite = $Sprite

signal level_done

func set_active(a : bool):
	if a:
		collision_mask = 2
	else:
		collision_mask = 0
	sprite.visible = a


func _on_LevelExit_body_entered(body):
	if body is Player:
		emit_signal("level_done")
