extends Node2D

onready var generator : Generator = $Generator

onready var player : Player = $Player
onready var nav : Navigation2D = $Navigation2D


func _ready():
	player.collision_layer = 0
	yield(get_tree(), "idle_frame")
	if generator.connect("done", self, "_on_Generator_done") != OK:
		printerr("Failed connecting signal \"done\" from Generator to World")
	generator.generate_level(player, nav)


func _on_Player_game_over():
	get_tree().call_group("Entity", "queue_free")
	get_tree().reload_current_scene()


func _on_Generator_done() -> void:
	yield(get_tree(), "idle_frame")
	player.collision_layer = 1 #TODO: adjust to correct layers
	if generator.exit.connect("level_done", self, "_on_Exit_level_done") != OK:
		printerr("Failed connecting signal \"done\" from Generator to World")


func _on_Exit_level_done() -> void:
	player.collision_layer = 0
	yield(get_tree(), "idle_frame")
	generator.generate_level(player, nav)
