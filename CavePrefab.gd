extends RoomPrefab
class_name CavePrefab


func generate_room(door_directions : Array, end_room : bool):
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
			tile_map.set_cellv(tile, tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile + Vector2.UP, tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile + Vector2.DOWN, tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile + Vector2.LEFT, tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile + Vector2.RIGHT, tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile + Vector2.ONE, tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile - Vector2.ONE, tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile + Vector2(-1, 1), tile_map.tile_set.find_tile_by_name("Floor"))
			tile_map.set_cellv(tile - Vector2(-1, 1), tile_map.tile_set.find_tile_by_name("Floor"))
