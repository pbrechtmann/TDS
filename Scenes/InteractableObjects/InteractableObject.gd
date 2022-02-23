extends Node2D
class_name InteractableObject

var highlight_material : Material = preload("res://Assets/Shaders/DropHighlight.material")

onready var sprite = $Sprite

func activate(_user : Entity) -> void:
	pass


func highlight() -> void:
	sprite.material = highlight_material


func clear_highlight() -> void:
	sprite.material = null
