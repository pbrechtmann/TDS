extends Node2D
class_name DropSpawner


var drop_scene = preload("res://Scenes/InteractableObjects/Drops/Drop.tscn")

var auto_drop_scene = preload("res://Scenes/InteractableObjects/Drops/AutomaticPickup/AutoDrop.tscn")
var item_drop_scene = preload("res://Scenes/InteractableObjects/Drops/ItemDrop.tscn")
var upgrade_drop_scene = preload("res://Scenes/InteractableObjects/Drops/UpgradeDrop.tscn")


func spawn_drop(tier : int, pos : Vector2, min_amount : int, max_amount : int, random_offset : bool = false) -> void:
	#TODO: determine drop by tier
	
	for _i in range(rand_range(min_amount, max_amount)):
		var drop = upgrade_drop_scene.instance()
		
		
		if random_offset:
			pos += Vector2(randf(), randf()).normalized() * rand_range(64, 128)
		
		spawn_auto_drop(AutoDrop.ATTRIBUTE.HEALTH, AutoDrop.TYPE.PERCENTAGE, 0.5, pos)
		
		drop.global_position = pos
		call_deferred("add_child", drop)


func spawn_item_drop(item : PackedScene, item_type : int, pos : Vector2) -> void:
	var drop : ItemDrop = item_drop_scene.instance()
	drop.global_position = pos
	drop.init(item, item_type)
	call_deferred("add_child", drop)


func spawn_upgrade_drop(upgrade : PackedScene, upgrade_type : int, pos : Vector2) -> void:
	var drop : UpgradeDrop = upgrade_drop_scene.instance()
	drop.global_position = pos
	drop.init(upgrade, upgrade_type)
	call_deferred("add_child", drop)


func spawn_auto_drop(attribute : int, variant : int, value : float, pos : Vector2) -> void:
	var drop : AutoDrop = auto_drop_scene.instance()
	drop.global_position = pos
	drop.init(attribute, variant, value)
	call_deferred("add_child", drop)


func clear() -> void:
	for c in get_children():
		c.queue_free()
