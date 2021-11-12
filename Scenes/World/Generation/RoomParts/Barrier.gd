extends Node2D

onready var sprite = $Sprite

var active = false


func set_active(a : bool):
	active = a
	sprite.visible = active
