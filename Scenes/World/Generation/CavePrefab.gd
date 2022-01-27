extends RoomPrefab
class_name CavePrefab

var floor_tiles : Array = []


func generate_room(door_directions : Array, end_room : bool) -> void:
	if end_room:
		door_directions.append(door_directions[0] * -1)
	for d in door_directions:
		var walker_pos : Vector2
		if rotation_degrees == 90:
			match d:
				Vector2.UP:
					walker_pos = doors[1] + Vector2.RIGHT * 2
				Vector2.LEFT:
					walker_pos = doors[3] + Vector2.UP * 2
				Vector2.RIGHT:
					walker_pos = doors[0] + Vector2.DOWN * 2
				Vector2.DOWN:
					walker_pos = doors[2] + Vector2.LEFT * 2
		else:
			match d:
				Vector2.UP:
					walker_pos = doors[0] + Vector2.DOWN * 2
				Vector2.LEFT:
					walker_pos = doors[1] + Vector2.RIGHT * 2
				Vector2.RIGHT:
					walker_pos = doors[2] + Vector2.LEFT * 2
				Vector2.DOWN:
					walker_pos = doors[3] + Vector2.UP * 2
					
		var rect = tile_map.get_used_rect().grow(-2)
		
		var walker = Walker.new(walker_pos, rect)
		var map = walker.walk(500)
		walker.queue_free()
		
		
		for tile in map:
			var brush = [tile, tile + Vector2.UP, tile + Vector2.DOWN, tile + Vector2.LEFT, tile + Vector2.RIGHT, tile + Vector2.ONE, tile - Vector2.ONE, tile + Vector2(-1, 1), tile - Vector2(-1, 1)]
			for pos in brush:
				tile_map.set_cellv(pos, tile_map.tile_set.find_tile_by_name("Floor"))
				if not floor_tiles.has(pos):
					floor_tiles.append(pos)
			
		
	generate_navpoly()


func generate_navpoly() -> void:
	floor_tiles.sort()
	var outline : PoolVector2Array = []
	
	var column_start : int = floor_tiles[0].x
	var column_end : int = floor_tiles[floor_tiles.size() - 1].x
	
	for t in floor_tiles:
		if [column_start, column_end].has(t.x):
			outline.append(t)
	
	var poly : NavigationPolygon = NavigationPolygon.new()
	poly.add_outline(outline)
	poly.make_polygons_from_outlines()
	
	nav_poly.navpoly = poly
