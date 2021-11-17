extends Node2D
class_name RoomPrefab

var barrier_scene : PackedScene = preload("res://Scenes/World/Generation/RoomParts/Barrier.tscn")
var spawner_scene : PackedScene = preload("res://Scenes/Entities/Spawners/Spawner.tscn")

var index : int
var doors : Array 

var barriers : Array
var barrier_tiles : Array
var spawners : Array
var spawner_tiles : Array

var player : Player
var nav : Navigation2D

onready var tile_map : TileMap = $Terrain
onready var spawn_map : TileMap = $Spawns

onready var area : Area2D = $Area2D
onready var nav_poly : NavigationPolygonInstance = $NavigationPolygonInstance


func _ready():
	set_process(false)
	doors = tile_map.get_used_cells_by_id(tile_map.tile_set.find_tile_by_name("Door"))
	barrier_tiles = spawn_map.get_used_cells_by_id(spawn_map.tile_set.find_tile_by_name("Door"))
	spawner_tiles = spawn_map.get_used_cells_by_id(spawn_map.tile_set.find_tile_by_name("Spawner"))
	if rotation_degrees == 90:
		spawn_map.position -= Vector2(0, spawn_map.cell_size.x)
		nav_poly.position -= Vector2(0, spawn_map.cell_size.x)
		area.position -= Vector2(0, spawn_map.cell_size.x)
	nav.navpoly_add(nav_poly.navpoly, nav_poly.global_transform)
	spawn_spawners()


func init(player : Player, nav : Navigation2D):
	self.player = player
	self.nav = nav


func spawn_barriers(map : TileMap):
	for i in range(barrier_tiles.size()):
		var b = barrier_tiles[i]
		if rotation_degrees == 90:
			b -= Vector2.UP
		var spawn_pos = spawn_map.map_to_world(b)
		var pos = spawn_map.to_global(spawn_pos)
		var map_pos = map.world_to_map(map.to_local(pos))
		if map.get_cellv(map_pos) == map.tile_set.find_tile_by_name("Floor"):
			var barrier = barrier_scene.instance()
			barrier.position = spawn_pos + Vector2.ONE * spawn_map.cell_size / 2
			if rotation_degrees == 90:
				barrier.position -= Vector2(0, spawn_map.cell_size.x) * 2
			
			if i == 1 or i == 2:
				barrier.rotation_degrees = -90
			
			barriers.append(barrier)
			add_child(barrier)
			barrier.set_active(false)


func spawn_spawners():
	for s in spawner_tiles:
		var spawner : Spawner = spawner_scene.instance()
		spawner.position = spawn_map.map_to_world(s) + Vector2.ONE * spawn_map.cell_size / 2
		if rotation_degrees == 90:
				spawner.position -= Vector2(0, spawn_map.cell_size.x)
		spawners.append(spawner)
		add_child(spawner)
		spawner.init(nav, player)


func activate_area():
	area.monitoring = true


func has_index(i : int):
	return i == index


func _process(_delta):
	try_open_room()


func try_open_room():
	for spawner in spawners:
		if is_instance_valid(spawner):
			return
	
	set_process(false)
	
	for b in barriers:
		b.set_active(false)


func _on_Area2D_body_entered(body):
	if body is Player:
		for s in spawners:
			if is_instance_valid(s):
				s.timer.start()
		for b in barriers:
			b.set_active(true)
	set_process(true)


func _on_Area2D_body_exited(body):
	if body is Player:
		area.set_deferred("monitoring", false)
