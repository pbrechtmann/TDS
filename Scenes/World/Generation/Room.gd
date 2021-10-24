extends RigidBody2D


var size : Vector2


func make_room(pos : Vector2, s : Vector2):
	position = pos
	size = s
	var shape = RectangleShape2D.new()
	shape.custom_solver_bias = 1
	shape.set_extents(size)
	$CollisionShape2D.shape = shape
