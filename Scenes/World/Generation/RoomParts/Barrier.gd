extends StaticBody2D
class_name Barrier

onready var sprite = $Sprite


func set_active(a : bool):
	if a:
		collision_layer = 1
	else:
		collision_layer = 0
	sprite.visible = a
