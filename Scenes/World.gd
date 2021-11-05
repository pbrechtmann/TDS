extends Node2D

onready var generator : Generator = $Generator

onready var nav = $Navigation2D
onready var player = $Player


func _ready():
	get_tree().call_group("Spawners", "init", nav, player)


func _on_Player_game_over():
	get_tree().call_group("Entity", "queue_free")
	get_tree().reload_current_scene()



func _on_Generator_done():
	var map_container : Node2D = generator.map_container
	generator.remove_child(map_container)
	nav.add_child(map_container)
	map_container.set_owner(self)
	player.global_position = generator.start_position
	generator.queue_free()
