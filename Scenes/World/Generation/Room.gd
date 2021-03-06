extends RigidBody2D
class_name RoomBody

var size : Vector2
var astar_index : int

var cave : bool = false

onready var collision = $CollisionShape2D

func init(s : Vector2, spacer : Vector2, tile_size : int, c : bool = false) -> void:
	size = s * tile_size / 2
	cave = c
	var shape = RectangleShape2D.new()
	shape.custom_solver_bias = 1
	shape.set_extents(size + spacer * tile_size)
	$CollisionShape2D.shape = shape
	size *= 2


func has_index(index : int) -> bool:
	if index == astar_index:
		return true
	return false
