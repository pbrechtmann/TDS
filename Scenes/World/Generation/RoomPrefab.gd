extends Node2D
class_name RoomPrefab

var index : int
var doors : Array 

onready var tile_map : TileMap = $Terrain
onready var spawn_map : TileMap = $Spawns

func _ready():
	doors = tile_map.get_used_cells_by_id(tile_map.tile_set.find_tile_by_name("Door"))

func has_index(i : int):
	return i == index
