extends Node2D
class_name Generator

var room_scene = preload("res://Scenes/World/Generation/Room.tscn")

var tile_size = 128
export var spacer : Vector2 = Vector2(6, 6) # Making sure rooms don't overlap

export var num_rooms_small : int = 5
export var num_rooms_medium : int = 3
export var num_rooms_large : int = 1
export var num_rooms_cave : int = 0

export var room_sizes_small = [Vector2(5, 7), Vector2(7, 5)]
export var room_sizes_medium = [Vector2(7, 9), Vector2(9, 7)]
export var room_sizes_large = [Vector2(9, 11), Vector2(11, 9)]
export var room_sizes_cave = [Vector2(25, 25)]

export var cyclic_paths : bool = true

var rooms_small : Array = []
var rooms_medium : Array = []
var rooms_large : Array = []
var rooms_cave : Array = []

var final_rooms : Array = []

var start_room = null
var end_room = null

var path : AStar2D
var door_connections : AStar2D
var door_points : Array = []


var start_position : Vector2
var player : Player
var nav : Navigation2D
var drop_spawner : DropSpawner

var exit : LevelExit

onready var room_container = $Rooms
onready var map_container : Node2D = $Maps
onready var map : TileMap = $Maps/TerrainMap

signal done

func generate_level(player : Player, nav : Navigation2D, drop_spawner : DropSpawner) -> void:
	for child in room_container.get_children():
		child.queue_free()
	for i in range(map.get_children().size()):
		map.get_child(i).queue_free()
	map.clear()
	
	self.player = player
	self.nav = nav
	self.drop_spawner = drop_spawner
	randomize()
	make_rooms()
	yield(get_tree().create_timer(0.1), "timeout")
	make_map()


func make_rooms() -> void:
	rooms_small = generate_room_bodies(num_rooms_small, room_sizes_small, room_container)
	rooms_medium = generate_room_bodies(num_rooms_medium, room_sizes_medium, room_container)
	rooms_large = generate_room_bodies(num_rooms_large, room_sizes_large, room_container)
	rooms_cave = generate_room_bodies(num_rooms_cave, room_sizes_cave, room_container, true)
	
	final_rooms = rooms_small + rooms_medium + rooms_large + rooms_cave
	
	final_rooms.shuffle()
	
	for room in final_rooms:
		room.set_collision_mask(512)
		room.set_collision_layer(512)
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	for room in final_rooms:
		room.position = room.position.snapped(Vector2(128, 128))
		room.mode = RigidBody2D.MODE_STATIC
	
	find_graph(final_rooms)


func generate_room_bodies(amount : int, sizes : Array, room_container : Node, cave : bool = false) -> Array:
	var res : Array = []
	
	while amount > 0:
		var room = room_scene.instance()
		room.init(sizes[randi() % sizes.size()], spacer, tile_size, cave)
		room.position = Vector2(rand_range(-1, 1), rand_range(-1, 1)).clamped(1)
		res.append(room)
		room_container.call_deferred("add_child", room)
		amount -= 1
	
	return res


func find_graph(rooms_in) -> void:
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
	
	if cyclic_paths:
		var delauney = Array(Geometry.triangulate_delaunay_2d(positions))

		while not delauney.empty():
			var p1 = delauney.pop_front()
			var p2 = delauney.pop_front()
			var p3 = delauney.pop_front()

			if is_loop_valid(p1, p2) and randf() < 0.2: 
				path.connect_points(p1, p2)
			if is_loop_valid(p1, p3) and randf() < 0.2:
				 path.connect_points(p1, p3)
			if is_loop_valid(p2, p3) and randf() < 0.2:
				 path.connect_points(p2, p3)


func is_loop_valid(p1 : int, p2 : int) -> bool:
	return not path.are_points_connected(p1, p2) and path.get_point_path(p1, p2).size() == 3 and not(has_start_room(p1, p2) or has_end_room(p1, p2))


func has_start_room(index1, index2) -> bool:
	if start_room:
		return index1 == start_room.astar_index or index2 == start_room.astar_index
	return false


func has_end_room(index1, index2) -> bool:
	if end_room:
		return index1 == end_room.astar_index or index2 == end_room.astar_index
	return false


func find_start_and_end() -> void:
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
	start_position = start_room.global_position + Vector2.ONE * tile_size / 2
	end_room = end


func make_map() -> void:
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
			map.set_cell(x, y, map.tile_set.find_tile_by_name("ToFill"))
	
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
		
		var new_room
		if room.cave:
			new_room = load("res://Scenes/World/Generation/CavePrefabs/CavePrefab" + str(x_size) + "x" + str(y_size) + ".tscn").instance()
		else:
			new_room = load("res://Scenes/World/Generation/RoomPrefabs/RoomPrefab" + str(x_size) + "x" + str(y_size) + ".tscn").instance()
		new_room.position = room.position
		new_room.index = room.astar_index
		if rotate:
			new_room.rotation_degrees = 90
		new_room.init(player, nav, map, drop_spawner)
		map.add_child(new_room)

	for room in final_rooms:
		var new_room
		for x in map.get_children():
			if x.has_index(room.astar_index):
				new_room = x
		var door_dirs = connect_doors(new_room, room)
		if new_room.has_method("generate_room"):
			new_room.generate_room(door_dirs, new_room.index == end_room.astar_index)
		merge_maps(map, new_room.tile_map)
	link_door_graph()
	carve_corridors()
	place_walls()
	map.update_bitmask_region()
	
	path.clear()
	door_connections.clear()
	door_points.clear()
	
	for child in room_container.get_children():
		child.queue_free()
	final_rooms.clear()
	
	
	player.global_position = start_position
	
	for r in map.get_children():
		r.spawn_barriers()
		r.activate_area()
		r.attach_nav_poly()
		if r.index == end_room.astar_index:
			exit = r.add_level_exit()
	
	emit_signal("done")


func connect_doors(room_prefab, room) -> Array:
	var doors : Array = [] + room_prefab.doors
	var doors_used : Array = []
	var rotated = room_prefab.rotation_degrees == 90
	if rotated:
		doors = [doors[1], doors[3], doors[0], doors[2]]
	for r in final_rooms:
		if path.are_points_connected(room.astar_index, r.astar_index):
			
			var start_dict : Dictionary = get_door_dict(room, room_prefab, doors, r)

			var t_room
			for x in map.get_children():
				if x.has_index(r.astar_index):
					t_room = x
			
			var t_doors = t_room.doors
			if t_room.rotation_degrees == 90:
				t_doors = [t_doors[1], t_doors[3], t_doors[0], t_doors[2]]
			
			var end_dict : Dictionary = get_door_dict(r, t_room, t_doors, room)
			
			door_points.append([start_dict, end_dict])
			doors_used.append(start_dict["dir"])
	return doors_used


func get_door_dict(start_room, start_room_prefab, doors : Array, target_room) -> Dictionary:
	var extents : Vector2 = start_room.collision.shape.get_extents()
	var center : Vector2 = start_room.position
	var tl : Vector2 = center - extents
	var tr : Vector2 = center + Vector2(extents.x, -extents.y)
	var bl : Vector2 = center - Vector2(extents.x, -extents.y)
	var br : Vector2 = center + extents
	
	var tl_angle : float = center.direction_to(tl).angle()
	var tr_angle : float = center.direction_to(tr).angle()
	var bl_angle : float = center.direction_to(bl).angle()
	var br_angle : float = center.direction_to(br).angle()
	
	var path_angle : float = center.direction_to(target_room.position).angle()
	
	var door_location : Vector2
	var door_direction : Vector2
	
	if path_angle >= tl_angle and path_angle < tr_angle:
		door_location = doors[0]
		door_direction = Vector2.UP
	elif path_angle >= tr_angle and path_angle < br_angle:
		door_location = doors[2]
		door_direction = Vector2.RIGHT
	elif path_angle >= tr_angle and path_angle < bl_angle:
		door_location = doors[3]
		door_direction = Vector2.DOWN
	else:
		door_location = doors[1]
		door_direction = Vector2.LEFT
	
	return {
		"pos": start_room_prefab.tile_map.to_global(start_room_prefab.tile_map.map_to_world(door_location)),
		"dir": door_direction
	}


func link_door_graph() -> void:
	var linked : Dictionary = {}
	door_connections = AStar2D.new()
	for x in door_points:
		var val1 : int
		var val2 : int
		var pos1 : Vector2 = x[0]["pos"]
		var pos2 : Vector2 = x[1]["pos"]
		if linked.has(pos1):
			val1 = linked[pos1]
			x[0]["index"] = val1
		else:
			val1 = door_connections.get_available_point_id()
			x[0]["index"] = val1
			linked[pos1] = val1
			door_connections.add_point(val1, pos1)
		if linked.has(pos2):
			val2 = linked[pos2]
			x[1]["index"] = val2
		else:
			val2 = door_connections.get_available_point_id()
			x[1]["index"] = val2
			linked[pos2] = val2
			door_connections.add_point(val2, pos2)
		door_connections.connect_points(val1, val2)


func carve_corridors() -> void:
	var path_search : AStar2D = AStar2D.new()
	for i in range(door_connections.get_point_count()):
		var door = map.world_to_map(door_connections.get_point_position(i))
		for j in door_connections.get_point_connections(i):
			var target = map.world_to_map(door_connections.get_point_position(j))
			
			var door_id = path_search.get_available_point_id()
			path_search.add_point(door_id, door)
			var target_id = path_search.get_available_point_id()
			path_search.add_point(target_id, target)
			
			var tl : Vector2 = Vector2(min(door.x, target.x), max(door.y, target.y))
			var br : Vector2 = Vector2(max(door.x, target.x), min(door.y, target.y))
			
			var x_diff = max(1, abs(tl.x - br.x))
			var y_diff = max(1, abs(tl.y - br.y))
			
			
			for x in range(x_diff):
				for y in range(y_diff):
					var point_pos = tl + Vector2(x, -y)
					if tile_is_valid(point_pos):
						path_search.add_point(path_search.get_available_point_id(), point_pos, point_pos.distance_squared_to(door) + point_pos.distance_squared_to(target))
			
			for p in path_search.get_points():
				connect_to_dir(path_search, p, Vector2.UP)
				connect_to_dir(path_search, p, Vector2.DOWN)
				connect_to_dir(path_search, p, Vector2.LEFT)
				connect_to_dir(path_search, p, Vector2.RIGHT)
				if path_search.get_point_connections(p).size() == 0:
					connect_to_dir(path_search, p, Vector2.UP * 2)
					connect_to_dir(path_search, p, Vector2.DOWN * 2)
					connect_to_dir(path_search, p, Vector2.LEFT * 2)
					connect_to_dir(path_search, p, Vector2.RIGHT * 2)
			
			
			var corridor : Array = path_search.get_point_path(door_id, target_id)
			for p in corridor:
				var floor_tile = map.tile_set.find_tile_by_name("Floor")
				map.set_cellv(p, floor_tile)
				map.set_cellv(p + Vector2.UP, floor_tile)
				map.set_cellv(p + Vector2.DOWN, floor_tile)
				map.set_cellv(p + Vector2.LEFT, floor_tile)
				map.set_cellv(p + Vector2.RIGHT, floor_tile)
				map.set_cellv(p + Vector2.ONE, floor_tile)
				map.set_cellv(p + Vector2.ONE * -1, floor_tile)
				map.set_cellv(p + Vector2(-1, 1), floor_tile)
				map.set_cellv(p + Vector2(1, -1), floor_tile)
			door_connections.disconnect_points(i, j)
			path_search.clear()


func connect_to_dir(astar : AStar2D, p : int, dir : Vector2) -> void:
	var q = astar.get_closest_point(astar.get_point_position(p) + dir)
	if q != p and not astar.are_points_connected(p, q):
		astar.connect_points(p, q)


func tile_is_valid(pos : Vector2) -> bool:
	var invalid_tiles : Array = [map.tile_set.find_tile_by_name("Wall")]
	var positions : Array = [pos, pos + Vector2.UP, pos + Vector2.DOWN, pos + Vector2.RIGHT, pos + Vector2.LEFT, pos + Vector2.ONE, pos + Vector2.ONE * -1, pos + Vector2(-1, 1), pos + Vector2(-1, 1) * -1]
	for x in positions:
		if invalid_tiles.has(map.get_cellv(x)):
			return false
	return true


func place_walls() -> void:
	for x in map.get_used_cells_by_id(map.tile_set.find_tile_by_name("ToFill")):
		map.set_cellv(x, map.tile_set.find_tile_by_name("Wall"))
	for x in map.get_used_cells_by_id(map.tile_set.find_tile_by_name("Door")):
		map.set_cellv(x, map.tile_set.find_tile_by_name("Wall"))


func carve(start : Vector2, direction : Vector2, steps : int, corner : bool = false) -> Vector2:
	var pos = Vector2.ZERO + start
	
	set_floor_cell(pos, direction)
	if corner:
		set_floor_cell(pos + direction * -1, direction)
	
	for _i in range(steps):
		pos += direction
		set_floor_cell(pos, direction)
	if corner:
		set_floor_cell(pos + direction, direction)
	return pos


func set_floor_cell(pos : Vector2, dir : Vector2):
	map.set_cellv(pos, map.tile_set.find_tile_by_name("Floor"))
	if dir == Vector2.UP or dir == Vector2.DOWN:
		map.set_cellv(pos + Vector2.RIGHT, map.tile_set.find_tile_by_name("Floor"))
		map.set_cellv(pos + Vector2.LEFT, map.tile_set.find_tile_by_name("Floor"))
	elif dir == Vector2.LEFT or dir == Vector2.RIGHT:
		map.set_cellv(pos + Vector2.UP, map.tile_set.find_tile_by_name("Floor"))
		map.set_cellv(pos + Vector2.DOWN, map.tile_set.find_tile_by_name("Floor"))


func get_door_dir(index : int) -> Vector2:
	for d in door_points:
		if d[0]["index"] == index:
			return d[0]["dir"]
	return Vector2.ZERO


func merge_maps(target : TileMap, input : TileMap) -> void:
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
