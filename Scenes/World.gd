extends Node2D

onready var generator : Generator = $Generator

onready var player : Player = $Player
onready var nav : Navigation2D = $Navigation2D


func _ready():
	generator.generate_level(player, nav)


func _on_Player_game_over():
	get_tree().call_group("Entity", "queue_free")
	get_tree().reload_current_scene()
