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
	var spawn_map : TileMap = generator.spawn_map
	generator.remove_child(map_container)
	nav.add_child(map_container)
	map_container.set_owner(self)
	player.global_position = generator.start_position
	generator.queue_free()
	
	for x in spawn_map.get_used_cells_by_id(spawn_map.tile_set.find_tile_by_name("Spawner")):
		var spawner_instance = load("res://Scenes/Entities/Spawners/Spawner.tscn").instance()
		spawner_instance.position = spawn_map.to_global(spawn_map.map_to_world(x)) + Vector2.ONE * spawn_map.cell_size / 2
		add_child(spawner_instance)
	get_tree().call_group("Spawners", "init", nav, player)
