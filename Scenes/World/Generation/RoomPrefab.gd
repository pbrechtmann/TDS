extends Node2D
class_name RoomPrefab

var barrier_scene : PackedScene = preload("res://Scenes/World/Generation/RoomParts/Barrier.tscn")
var level_exit_scene : PackedScene = preload("res://Scenes/World/Generation/RoomParts/LevelExit.tscn")
var spawner_scene : PackedScene = preload("res://Scenes/Entities/NPCs/Spawners/Spawner.tscn")

var index : int
var doors : Array 

var barriers : Array
var barrier_tiles : Array
var spawners : Array
var spawner_tiles : Array

var exit_tile : Vector2
var exit : LevelExit

var player : Player
var nav : Navigation2D
var drop_spawner : DropSpawner

var global_map : TileMap

onready var tile_map : TileMap = $Terrain
onready var spawn_map : TileMap = $Spawns

onready var area : Area2D = $Area2D
onready var nav_poly : NavigationPolygonInstance = $NavigationPolygonInstance


func _ready() -> void:
	set_process(false)
	doors = tile_map.get_used_cells_by_id(tile_map.tile_set.find_tile_by_name("Door"))
	barrier_tiles = spawn_map.get_used_cells_by_id(spawn_map.tile_set.find_tile_by_name("Door"))
	spawner_tiles = spawn_map.get_used_cells_by_id(spawn_map.tile_set.find_tile_by_name("Spawner"))
	if rotation_degrees == 90:
		spawn_map.position -= Vector2(0, spawn_map.cell_size.x)
		nav_poly.position -= Vector2(0, spawn_map.cell_size.x)
		area.position -= Vector2(0, spawn_map.cell_size.x)
	spawn_spawners()


func init(player : Player, nav : Navigation2D, map : TileMap, drop_spawner : DropSpawner) -> void:
	self.player = player
	self.nav = nav
	self.global_map = map
	self.drop_spawner = drop_spawner


func attach_nav_poly() -> void:
	nav.navpoly_add(nav_poly.navpoly, nav_poly.global_transform)


func spawn_barriers() -> void:
	for i in range(barrier_tiles.size()):
		var b = barrier_tiles[i]
		if rotation_degrees == 90:
			b -= Vector2.UP
		var spawn_pos = spawn_map.map_to_world(b)
		var pos = spawn_map.to_global(spawn_pos)
		var map_pos = global_map.world_to_map(global_map.to_local(pos))
		if global_map.get_cellv(map_pos) == global_map.tile_set.find_tile_by_name("Floor"):
			var barrier : Barrier = barrier_scene.instance()
			barrier.position = spawn_pos + Vector2.ONE * spawn_map.cell_size / 2
			if rotation_degrees == 90:
				barrier.position -= Vector2(0, spawn_map.cell_size.x) * 2
			
			match i:
				0:
					exit_tile = barrier_tiles[3]
				1:
					exit_tile = barrier_tiles[2]
					barrier.rotation_degrees = -90
				2:
					exit_tile = barrier_tiles[1]
					barrier.rotation_degrees = -90
				3:
					exit_tile = barrier_tiles[0]
			
			barriers.append(barrier)
			add_child(barrier)
			barrier.set_active(false)


func spawn_spawners() -> void:
	for s in spawner_tiles:
		var spawner : Spawner = spawner_scene.instance()
		spawner.position = spawn_map.map_to_world(s) + Vector2.ONE * spawn_map.cell_size / 2
		if rotation_degrees == 90:
				spawner.position -= Vector2(0, spawn_map.cell_size.x)
		spawners.append(spawner)
		add_child(spawner)
		spawner.init(nav, player, drop_spawner)


func add_level_exit() -> LevelExit:
	var exit_position : Vector2 = spawn_map.map_to_world(exit_tile) + Vector2.ONE * spawn_map.cell_size / 2
	exit = level_exit_scene.instance()
	exit.position = exit_position
	if exit.position.y == (spawn_map.cell_size / 2).y:
		exit.rotation_degrees = -90
	if rotation_degrees == 90:
		exit.position -= Vector2(0, spawn_map.cell_size.x)
	add_child(exit)
	exit.set_active(false)
	return exit


func activate_level_exit() -> void:
	var to_clear : Array = [exit_tile]
	if exit.rotation_degrees == -90:
		to_clear.append_array([exit_tile + Vector2.UP, exit_tile + Vector2.DOWN])
	else:
		to_clear.append_array([exit_tile + Vector2.LEFT, exit_tile + Vector2.RIGHT])
			
		
	for v in to_clear:
		if rotation_degrees == 90:
			v -= Vector2.UP
		var map_pos = global_map.world_to_map(global_map.to_local(spawn_map.to_global(spawn_map.map_to_world(v))))
		global_map.set_cellv(map_pos, -1)
	exit.set_active(true)


func activate_area() -> void:
	area.collision_mask = 1 # TODO: adjust to correct layers
	area.monitoring = true


func has_index(i : int) -> bool:
	return i == index


func _process(_delta) -> void:
	try_open_room()


func try_open_room() -> void:
	for spawner in spawners:
		if is_instance_valid(spawner):
			return
	
	set_process(false)
	
	for b in barriers:
		b.set_active(false)
	if exit:
		activate_level_exit()


func _on_Area2D_body_entered(body) -> void:
	if body is Player:
		for s in spawners:
			if is_instance_valid(s):
				s.timer.start()
		for b in barriers:
			b.set_active(true)
	set_process(true)


func _on_Area2D_body_exited(body) -> void:
	if body is Player:
		area.set_deferred("monitoring", false)
