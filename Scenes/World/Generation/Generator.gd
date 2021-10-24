extends Node2D

var room = preload("res://Scenes/World/Generation/Room.tscn")


var tile_size = 128
var num_rooms = 50
var min_size = 5
var max_size = 11

var cull_percent = 0.5

var room_positions = []
var delauney_points = []

onready var room_container = $Rooms

func _ready():
	randomize()
	make_rooms()


func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(0, 0)
		var r = room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		room_container.add_child(r)
	yield(get_tree().create_timer(1), "timeout")
	for room in room_container.get_children():
		if randf() < cull_percent:
			room.queue_free()
		else:
			room.position = room.position.snapped(Vector2(128, 128))
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(room.position)
	delauney_points = Geometry.triangulate_delaunay_2d(room_positions)


func _draw():
	for room in room_container.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color.darkorchid, false)
	if not room_positions.empty() and not delauney_points.empty():
		for index in delauney_points.size() / 3:
			var poly : PoolVector2Array = []
			for n in range(3):
				poly.append(room_positions[delauney_points[(index * 3) + n]])
			for n in range(poly.size() - 1):
				draw_line(poly[n], poly[n + 1], Color.darkorange)


func _process(delta):
	update()


func _input(event):
	if event.is_action_pressed("ui_select"):
		for room in room_container.get_children():
			room.queue_free()
			room_positions.clear()
		make_rooms()
