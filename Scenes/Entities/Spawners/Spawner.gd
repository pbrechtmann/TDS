extends NPC
class_name Spawner

export(PackedScene) var npc


func spawn() -> NPC:
	var new_npc = npc.instance()
	new_npc.init(nav, target)
	
	return new_npc


func _on_Timer_timeout():
	add_child(spawn())
