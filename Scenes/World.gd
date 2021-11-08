extends Node2D

onready var generator = $Generator

onready var player = $Player


func _ready():
	generator.generate_level(player)


func _on_Player_game_over():
	get_tree().call_group("Entity", "queue_free")
	get_tree().reload_current_scene()
