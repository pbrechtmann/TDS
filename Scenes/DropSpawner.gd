extends Node2D
class_name DropSpawner


var drop_scene = preload("res://Scenes/InteractableObjects/Drops/Drop.tscn")


func spawn_drop(tier : int, pos : Vector2, min_amount : int, max_amount : int, random_offset : bool = false) -> void:
	#TODO: determine drop by tier
	
	for _i in range(rand_range(min_amount, max_amount)):
		var drop = drop_scene.instance()
		
		if random_offset:
			pos += Vector2(randf(), randf()).normalized() * rand_range(64, 128)
		
		drop.global_position = pos
		call_deferred("add_child", drop)
