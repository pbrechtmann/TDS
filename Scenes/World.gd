extends Node2D

onready var nav = $Navigation2D
onready var player = $Player


func _ready():
	get_tree().call_group("Spawners", "init", nav, player)


func _on_Player_game_over():
	get_tree().call_group("Entity", "queue_free")
	get_tree().reload_current_scene()
