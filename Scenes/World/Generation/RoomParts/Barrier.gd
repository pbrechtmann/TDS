extends StaticBody2D

onready var sprite = $Sprite


func set_active(a : bool):
	if a:
		collision_layer = 1 #TODO: adjust to correct layers
	else:
		collision_layer = 0
	sprite.visible = a
