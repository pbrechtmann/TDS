extends Node2D

var room_scene = preload("res://Scenes/World/Generation/Room.tscn")


var tile_size = 128
var num_rooms = 20

var spacer : Vector2 = Vector2(3, 3) #making sure rooms don't bleed into each other

var num_rooms_small : int = 10
var num_rooms_medium : int = 5
var num_rooms_large : int = 4

var num_rooms_small_target : int = 5
var num_rooms_medium_target : int = 2
var num_rooms_large_target : int = 1

var room_sizes_small = [Vector2(5, 7), Vector2(7, 5)]
var room_sizes_medium = [Vector2(7, 9), Vector2(9, 7)]
var room_sizes_large = [Vector2(9, 11), Vector2(11, 9)]

var rooms_small : Array = []
var rooms_medium : Array = []
var rooms_large : Array = []

var cull_percent = 0.5

var final_rooms : Array = []


var start_room = null
var end_room = null

var path : AStar2D

onready var room_container = $Rooms

onready var map = $TileMap

func _ready():
	randomize()
	make_rooms()


func make_rooms():
	rooms_small = generate_room_bodies(num_rooms_small, room_sizes_small)
	rooms_medium = generate_room_bodies(num_rooms_medium, room_sizes_medium)
	rooms_large = generate_room_bodies(num_rooms_large, room_sizes_large)

	var r = room_container.get_children()
	r.shuffle()

	for room in r:
		room.set_collision_mask(512)
		room.set_collision_layer(512)

	yield(get_tree().create_timer(1), "timeout")

	rooms_small = cull_rooms(num_rooms_small_target, rooms_small)
	rooms_medium = cull_rooms(num_rooms_medium_target, rooms_medium)
	rooms_large = cull_rooms(num_rooms_large_target, rooms_large)
	
	for room in room_container.get_children():
		if not rooms_small.has(room) and not rooms_medium.has(room) and not rooms_large.has(room):
			room.queue_free()
			continue
		room.position = room.position.snapped(Vector2(128, 128))
		room.mode = RigidBody2D.MODE_STATIC
		final_rooms.append(room)
		#room.collision.shape.set_extents(room.size * tile_size)

	find_tree(final_rooms)


func generate_room_bodies(amount : int, sizes : Array):
	var res : Array = []
	for _i in range(amount):
		var r = room_scene.instance()
		r.make_room(sizes[randi() % sizes.size()], spacer, tile_size)
		res.append(r)
		room_container.add_child(r)
	return res


func cull_rooms(target_amount : int, rooms : Array) -> Array:
	while rooms.size() > target_amount:
		rooms.shuffle()
		rooms.remove(0)
	return rooms


func _draw():
	for room in rooms_small:
		if not (room == start_room or room == end_room):
			draw_rect(room_to_rect(room), Color.darkorchid, false, 50, true)
			draw_rect(room_to_rect(room, true), Color.darkorchid, false, 50, true)
	for room in rooms_medium:
		if not (room == start_room or room == end_room):
			draw_rect(room_to_rect(room), Color.darkturquoise, false, 50, true)
			draw_rect(room_to_rect(room, true), Color.darkturquoise, false, 50, true)
	for room in rooms_large:
		if not (room == start_room or room == end_room):
			draw_rect(room_to_rect(room), Color.darkred, false, 50, true)
			draw_rect(room_to_rect(room, true), Color.darkred, false, 50, true)
	if start_room:
		draw_rect(room_to_rect(start_room), Color.green, false, 50, true)
		draw_rect(room_to_rect(start_room, true), Color.green, false, 50, true)
	if end_room:
		draw_rect(room_to_rect(end_room), Color.yellow, false, 50, true)
		draw_rect(room_to_rect(end_room, true), Color.yellow, false, 50, true)
	if path:
		for p in path.get_points():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color.darkorange, 50, true)


func _process(_delta):
	update()


func find_tree(rooms_in):
	path = AStar2D.new()
	
	var rooms = [] + rooms_in
	
	var positions = []
	var index = 0
	for r in rooms:
		r.astar_index = index
		index += 1
		positions.append(r.position)
	
	var r = rooms.pop_front()
	path.add_point(r.astar_index, r.position)
	
	while rooms:
		var min_distance = INF # smallest distance
		var min_room = null # respective room
		var pos = null # current room
		
		for point1 in path.get_points():
			var point1_pos = path.get_point_position(point1)
			
			for point2 in rooms:
				var point2_pos = point2.position
				var test_distance = point1_pos.distance_to(point2_pos)
				if test_distance < min_distance:
					min_distance = test_distance
					min_room = point2
					pos = point1_pos
		
		path.add_point(min_room.astar_index, min_room.position)
		path.connect_points(path.get_closest_point(pos), min_room.astar_index)
		
		rooms.erase(min_room)
	
	find_start_and_end()
	
	var delauney = Array(Geometry.triangulate_delaunay_2d(positions))

	while not delauney.empty():
		var p1 = delauney.pop_front()
		var p2 = delauney.pop_front()
		var p3 = delauney.pop_front()

		if not path.are_points_connected(p1, p2) and randf() < 0.1 and not(has_start_room(p1, p2) or has_end_room(p1, p2)): 
			path.connect_points(p1, p2)
		if not path.are_points_connected(p1, p3) and randf() < 0.1 and not(has_start_room(p1, p3) or has_end_room(p1, p3)):
			 path.connect_points(p1, p3)
		if not path.are_points_connected(p2, p3) and randf() < 0.1 and not(has_start_room(p2, p3) or has_end_room(p2, p3)):
			 path.connect_points(p2, p3)


func has_start_room(index1, index2) -> bool:
	if start_room:
		return index1 == start_room.astar_index or index2 == start_room.astar_index
	return false


func has_end_room(index1, index2) -> bool:
	if end_room:
		return index1 == end_room.astar_index or index2 == end_room.astar_index
	return false


func find_start_and_end():
	var leaf_rooms_index : Array = []
	var leaf_rooms : Array = []
	for point in path.get_points():
		if path.get_point_connections(point).size() == 1:
			leaf_rooms_index.append(point)

	for r in final_rooms:
		for i in range(leaf_rooms_index.size()):
			if r.has_index(leaf_rooms_index[i]):
				leaf_rooms.append(r)
	
	var start = null
	var end = null
	var path_length = 0
	
	while not leaf_rooms.empty():
		var s = leaf_rooms.pop_front()
		for r in leaf_rooms:
			var l = path.get_id_path(s.astar_index, r.astar_index).size()
			if l > path_length:
				path_length = l
				start = s
				end = r
	
	if start.size > end.size:
		var temp = end
		end = start
		start = temp
	
	start_room = start
	end_room = end


func _input(event):
	if event.is_action_pressed("ui_select"):
		for room in final_rooms:
			room.queue_free()
		if path:
			path.clear()
		final_rooms.clear()
		start_room = null
		end_room = null
		map.clear()
		for x in map.get_children():
			x.queue_free()
		make_rooms()
	if event.is_action_pressed("ui_focus_next"):
		make_map()


func make_map():
	for r in final_rooms:
		r.position = r.position.snapped(Vector2(tile_size, tile_size))
	map.clear()
	
	var full_map_rect = Rect2()
	for room in final_rooms:
		var r = room_to_rect(room)
		full_map_rect = full_map_rect.merge(r)
	
	var top_left = map.world_to_map(full_map_rect.position)
	var bottom_right = map.world_to_map(full_map_rect.end)
	
	for x in range(top_left.x, bottom_right.x):
		for y in range(top_left.y, bottom_right.y):
			map.set_cell(x, y, map.tile_set.find_tile_by_name("Wall"))
	
	for room in final_rooms:
		var size = (room.size / tile_size)
		var r = room_to_rect(room, true)
		r.size += Vector2.ONE * tile_size
	
		var tl = map.world_to_map(r.position)
		var br = map.world_to_map(r.end)
	
		for x in range(tl.x, br.x):
			for y in range(tl.y, br.y):
				map.set_cell(x, y, -1)
		
		var rotate = size.x <= size.y
		var x_size = size.x if rotate else size.y
		var y_size = size.y if rotate else size.x
		
		var new_room = load("res://Scenes/World/Generation/RoomPrefabs/RoomPrefab" + str(x_size) + "x" + str(y_size) + ".tscn").instance()
		new_room.position = room.position
		if rotate:
			new_room.rotation_degrees = 90
		map.add_child(new_room)

	

	map.update_bitmask_region()


func room_to_rect(r, with_spacer : bool = false) -> Rect2:
	var room_extents : Vector2  = r.collision.shape.get_extents()
	if with_spacer:
		room_extents -= (spacer * tile_size)
	return Rect2(r.position - room_extents, room_extents * 2)
