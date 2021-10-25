extends RigidBody2D


var size : Vector2
var astar_index : int

func make_room(s : Vector2, spacer : Vector2):
	size = s
	var shape = RectangleShape2D.new()
	shape.custom_solver_bias = 1
	shape.set_extents(size + spacer)
	$CollisionShape2D.shape = shape


func has_index(index : int) -> bool:
	if index == astar_index:
		return true
	return false
