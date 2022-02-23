extends Node2D
class_name DropSpawner


var drop_scene = preload("res://Scenes/InteractableObjects/Drops/Drop.tscn")

var auto_drop_scene = preload("res://Scenes/InteractableObjects/Drops/AutomaticPickup/AutoDrop.tscn")
var item_drop_scene = preload("res://Scenes/InteractableObjects/Drops/ItemDrop.tscn")
var upgrade_drop_scene = preload("res://Scenes/InteractableObjects/Drops/UpgradeDrop.tscn")


func spawn_drop(tier : int, pos : Vector2, min_amount : int, max_amount : int, random_offset : bool = false) -> void:
	
	for _i in range(rand_range(min_amount, max_amount)):
		var drop_dict : Dictionary
		match tier:
			1:
				drop_dict = LootData.tier_1[randi() % LootData.tier_1.size()]
			2:
				drop_dict = LootData.tier_2[randi() % LootData.tier_2.size()]
			3:
				drop_dict = LootData.tier_3[randi() % LootData.tier_3.size()]
			4:
				drop_dict = LootData.tier_4[randi() % LootData.tier_4.size()]
		
		if random_offset:
			pos += Vector2(randf(), randf()).normalized() * rand_range(64, 128)
		
		
		match drop_dict["drop_type"]:
			"auto":
				spawn_auto_drop(drop_dict["attribute"], drop_dict["type"], drop_dict["value"], pos)
			"item":
				spawn_item_drop(drop_dict["scene"], drop_dict["type"], drop_dict["texture"], pos)
			"upgrade":
				spawn_upgrade_drop(drop_dict["scene"], drop_dict["type"], drop_dict["texture"], pos)


func spawn_item_drop(item : PackedScene, item_type : int, tex : Texture, pos : Vector2) -> void:
	var drop : ItemDrop = item_drop_scene.instance()
	drop.global_position = pos
	drop.init(item, item_type, tex)
	call_deferred("add_child", drop)


func spawn_upgrade_drop(upgrade : PackedScene, upgrade_type : int, tex : Texture, pos : Vector2) -> void:
	var drop : UpgradeDrop = upgrade_drop_scene.instance()
	drop.global_position = pos
	drop.init(upgrade, upgrade_type, tex)
	call_deferred("add_child", drop)


func spawn_auto_drop(attribute : int, variant : int, value : float, pos : Vector2) -> void:
	var drop : AutoDrop = auto_drop_scene.instance()
	drop.global_position = pos
	drop.init(attribute, variant, value)
	call_deferred("add_child", drop)


func clear() -> void:
	for c in get_children():
		c.queue_free()
