extends Node2D
class_name Generator

var room_scene = preload("res://Scenes/World/Generation/Room.tscn")

var tile_size = 128
var spacer : Vector2 = Vector2(3, 3) # Making sure rooms don't overlap

var num_rooms_small : int = 5
var num_rooms_medium : int = 3
var num_rooms_large : int = 1

var room_sizes_small = [Vector2(5, 7), Vector2(7, 5)]
var room_sizes_medium = [Vector2(7, 9), Vector2(9, 7)]
var room_sizes_large = [Vector2(9, 11), Vector2(11, 9)]

var rooms_small : Array = []
var rooms_medium : Array = []
var rooms_large : Array = []

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
	rooms_small = generate_room_bodies(num_rooms_small, room_sizes_small, room_container)
	rooms_medium = generate_room_bodies(num_rooms_medium, room_sizes_medium, room_container)
	rooms_large = generate_room_bodies(num_rooms_large, room_sizes_large, room_container)
	
	final_rooms = rooms_small + rooms_medium + rooms_large
	
	for room in final_rooms:
		room.set_collision_mask(512)
		room.set_collision_layer(512)
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	for room in final_rooms:
		room.position = room.position.snapped(Vector2(128, 128))
		room.mode = RigidBody2D.MODE_STATIC
	
	find_graph(final_rooms)


func generate_room_bodies(amount : int, sizes : Array, room_container : Node):
	var res : Array = []
	
	while amount > 0:
		var room = room_scene.instance()
		room.init(sizes[randi() % sizes.size()], spacer, tile_size)
		res.append(room)
		room_container.add_child(room)
		amount -= 1
	
	return res


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


func find_graph(rooms_in):
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
	
#	var delauney = Array(Geometry.triangulate_delaunay_2d(positions))
#
#	while not delauney.empty():
#		var p1 = delauney.pop_front()
#		var p2 = delauney.pop_front()
#		var p3 = delauney.pop_front()
#
#		if not path.are_points_connected(p1, p2) and randf() < 0.1 and not(has_start_room(p1, p2) or has_end_room(p1, p2)): 
#			path.connect_points(p1, p2)
#		if not path.are_points_connected(p1, p3) and randf() < 0.1 and not(has_start_room(p1, p3) or has_end_room(p1, p3)):
#			 path.connect_points(p1, p3)
#		if not path.are_points_connected(p2, p3) and randf() < 0.1 and not(has_start_room(p2, p3) or has_end_room(p2, p3)):
#			 path.connect_points(p2, p3)


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
		
		var new_room : RoomPrefab = load("res://Scenes/World/Generation/RoomPrefabs/RoomPrefab" + str(x_size) + "x" + str(y_size) + ".tscn").instance()
		new_room.position = room.position
		new_room.index = room.astar_index
		if rotate:
			new_room.rotation_degrees = 90
		map.add_child(new_room)

	for room in final_rooms:
		var new_room : RoomPrefab
		for x in map.get_children():
			if x.has_index(room.astar_index):
				new_room = x
		carve_corridor(new_room, room)
		merge_maps(map, new_room.tile_map)

	map.update_bitmask_region()



func carve_corridor(room_map : RoomPrefab, room):
	var doors = [] + room_map.doors
	var rotated = room_map.rotation_degrees == 90
	if rotated:
		doors = [doors[1], doors[3], doors[0], doors[2]]
	var doors_to_delete = []
	for r in final_rooms:
		if path.are_points_connected(room.astar_index, r.astar_index):
			
			var extents : Vector2 = room.collision.shape.get_extents()
			var center : Vector2 = room.position
			var tl : Vector2 = center - extents
			var tr : Vector2 = center + Vector2(extents.x, -extents.y)
			var bl : Vector2 = center - Vector2(extents.x, -extents.y)
			var br : Vector2 = center + extents
			
			var tl_angle : float = center.direction_to(tl).angle()
			var tr_angle : float = center.direction_to(tr).angle()
			var bl_angle : float = center.direction_to(bl).angle()
			var br_angle : float = center.direction_to(br).angle()
			
			var path_angle : float = center.direction_to(r.position).angle()
			
			var door_location : Vector2
			var door_direction : Vector2
			
			if path_angle >= tl_angle and path_angle < tr_angle:
				doors_to_delete.append(doors[0])
				door_location = doors[0]
				door_direction = Vector2.UP
				if rotated:
					doors_to_delete.append(doors[0] + Vector2.DOWN)
					doors_to_delete.append(doors[0] + Vector2.UP)
				else:
					doors_to_delete.append(doors[0] + Vector2.RIGHT)
					doors_to_delete.append(doors[0] + Vector2.LEFT)
			elif path_angle >= tr_angle and path_angle < br_angle:
				doors_to_delete.append(doors[2])
				door_location = doors[2]
				door_direction = Vector2.RIGHT
				if rotated:
					doors_to_delete.append(doors[2] + Vector2.RIGHT)
					doors_to_delete.append(doors[2] + Vector2.LEFT)
				else:
					doors_to_delete.append(doors[2] + Vector2.DOWN)
					doors_to_delete.append(doors[2] + Vector2.UP)
			elif path_angle >= tr_angle and path_angle < bl_angle:
				doors_to_delete.append(doors[3])
				door_location = doors[3]
				door_direction = Vector2.DOWN
				if rotated:
					doors_to_delete.append(doors[3] + Vector2.DOWN)
					doors_to_delete.append(doors[3] + Vector2.UP)
				else:
					doors_to_delete.append(doors[3] + Vector2.RIGHT)
					doors_to_delete.append(doors[3] + Vector2.LEFT)
			else:
				doors_to_delete.append(doors[1])
				door_location = doors[1]
				door_direction = Vector2.LEFT
				if rotated:
					doors_to_delete.append(doors[1] + Vector2.RIGHT)
					doors_to_delete.append(doors[1] + Vector2.LEFT)
				else:
					doors_to_delete.append(doors[1] + Vector2.DOWN)
					doors_to_delete.append(doors[1] + Vector2.UP)
			
			
			var t_room : RoomPrefab
			for x in map.get_children():
				if x.has_index(r.astar_index):
					t_room = x
			
			var t_extents : Vector2 = r.collision.shape.get_extents()
			var t_center : Vector2 = r.position
			var t_tl : Vector2 = t_center - t_extents
			var t_tr : Vector2 = t_center + Vector2(t_extents.x, -t_extents.y)
			var t_bl : Vector2 = t_center - Vector2(t_extents.x, -t_extents.y)
			var t_br : Vector2 = t_center + t_extents
			
			var t_tl_angle : float = t_center.direction_to(t_tl).angle()
			var t_tr_angle : float = t_center.direction_to(t_tr).angle()
			var t_bl_angle : float = t_center.direction_to(t_bl).angle()
			var t_br_angle : float = t_center.direction_to(t_br).angle()
			
			var t_path_angle : float = t_center.direction_to(t_room.position).angle()
			var t_room_doors = [] + t_room.doors
			var t_rotated = t_room.rotation_degrees == 90
			if t_rotated:
				t_room_doors = [t_room_doors[1], t_room_doors[3], t_room_doors[0], t_room_doors[2]]
			var t_door
			
			if t_path_angle >= t_tl_angle and t_path_angle < t_tr_angle:
				t_door = t_room_doors[0]
			elif t_path_angle >= t_tr_angle and t_path_angle < t_br_angle:
				t_door = t_room_doors[2]
			elif t_path_angle >= t_tr_angle and t_path_angle < t_bl_angle:
				t_door = t_room_doors[3]
			else:
				t_door = t_room_doors[1]
		
			var t_door_transformed = room_map.tile_map.world_to_map(room_map.tile_map.to_local(t_room.tile_map.to_global(t_room.tile_map.map_to_world(t_door))))
			
			var carve_direction : Vector2 = Vector2.ZERO
			
			if t_door_transformed.x == door_location.x:
				carve_direction = Vector2.DOWN if t_door_transformed.y > door_location.y else Vector2.UP
				carve(room_map.tile_map, door_location, carve_direction, ceil((abs(t_door_transformed.y - door_location.y) / 2)))
			else:
				var steps : int
				if door_direction == Vector2.UP or door_direction == Vector2.DOWN:
					steps = int(abs(t_door_transformed.y - door_location.y))
				elif door_direction == Vector2.LEFT or door_direction == Vector2.RIGHT:
					steps = int(abs(t_door_transformed.x - door_location.x))
				carve(room_map.tile_map, door_location, carve_direction, steps)


			if t_door_transformed.y == door_location.y:
				carve_direction = Vector2.RIGHT if t_door_transformed.x > door_location.x else Vector2.LEFT
				carve(room_map.tile_map, door_location, carve_direction, ceil(abs(t_door_transformed.x - door_location.x) / 2))
			else:
				var steps : int
				if door_direction == Vector2.UP or door_direction == Vector2.DOWN:
					steps = int(abs(t_door_transformed.y - door_location.y))
				elif door_direction == Vector2.LEFT or door_direction == Vector2.RIGHT:
					steps = int(abs(t_door_transformed.x - door_location.x))
				carve(room_map.tile_map, door_location, carve_direction, steps)


		
	for d in doors_to_delete:
		room_map.tile_map.set_cellv(d, room_map.tile_map.tile_set.find_tile_by_name("Floor"))
		if doors.has(d):
			doors.erase(d)
	
	for d in doors:
		room_map.tile_map.set_cellv(d, room_map.tile_map.tile_set.find_tile_by_name("Wall"))


func carve(tilemap : TileMap, start : Vector2, direction : Vector2, steps : int):
	if direction == Vector2.UP or direction == Vector2.DOWN:
		for i in range(steps):
			start += direction
			tilemap.set_cellv(start, tilemap.tile_set.find_tile_by_name("Floor"))
			tilemap.set_cellv(start + Vector2.RIGHT, tilemap.tile_set.find_tile_by_name("Floor"))
			tilemap.set_cellv(start + Vector2.LEFT, tilemap.tile_set.find_tile_by_name("Floor"))
	elif direction == Vector2.LEFT or direction == Vector2.RIGHT:
		for i in range(steps):
			start += direction
			tilemap.set_cellv(start, tilemap.tile_set.find_tile_by_name("Floor"))
			tilemap.set_cellv(start + Vector2.UP, tilemap.tile_set.find_tile_by_name("Floor"))
			tilemap.set_cellv(start + Vector2.DOWN, tilemap.tile_set.find_tile_by_name("Floor"))


func merge_maps(target : TileMap, input : TileMap):
	var cells = input.get_used_cells()
	for cell in cells:
		var tile : int = input.get_cellv(cell)
		var target_location : Vector2 = target.world_to_map(target.to_local(input.to_global(input.map_to_world(cell))))
		target.set_cellv(target_location, tile)
	input.clear()


func room_to_rect(r, with_spacer : bool = false) -> Rect2:
	var room_extents : Vector2  = r.collision.shape.get_extents()
	if with_spacer:
		room_extents -= (spacer * tile_size)
	return Rect2(r.position - room_extents, room_extents * 2)
