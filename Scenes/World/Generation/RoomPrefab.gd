extends Node2D
class_name RoomPrefab

var barrier = preload("res://Scenes/World/Door.tscn")

var index : int
var doors : Array 
var door_cells : Array

var barriers : Array

onready var tile_map : TileMap = $Terrain
onready var spawn_map : TileMap = $Spawns

onready var area : Area2D = $Area2D


var test_positions : Array

func _ready():
	doors = tile_map.get_used_cells_by_id(tile_map.tile_set.find_tile_by_name("Door"))
	door_cells = spawn_map.get_used_cells_by_id(spawn_map.tile_set.find_tile_by_name("Door"))
	if rotation_degrees == 90:
		door_cells = [door_cells[1], door_cells[3], door_cells[0], door_cells[2]]
		spawn_map.position -= Vector2(0, 128)
		area.position -= Vector2(0, 128)


func update_barrier_positions(map : TileMap):
	for cell in door_cells:
		var global_cell = spawn_map.to_global(spawn_map.map_to_world(cell) * 128)
		var world_cell = map.world_to_map(global_cell)
		test_positions.append(world_cell)
#		if  == map.tile_set.find_tile_by_name("Wall"):
#			door_cells.erase(cell)
	spawn_barriers()


func spawn_barriers():
	for i in range(door_cells.size()):
		var b = barrier.instance()
		b.position = spawn_map.map_to_world(door_cells[i])
		if i == 1 or i == 2:
			b.rotation_degrees = 90 
		if rotation_degrees == 90:
			b.position += Vector2(64, -64)
		else:
			b.position += Vector2(64, 64)
		b.enabled = false
		barriers.append(b)
		add_child(b)


func has_index(i : int):
	return i == index


func _on_Area2D_body_entered(body):
	if body is Player:
		for b in barriers:
			b.enable()



func _process(delta):
	update()

func _draw():
	for x in test_positions:
		draw_circle(x, 100, Color.antiquewhite)
