extends Node2D

var enabled : bool = false

onready var sprite = $Sprite

func _ready():
	if enabled:
		enable()
	else:
		disable()


func disable():
	sprite.visible = false


func enable():
	sprite.visible = true
