extends NPC
class_name Spawner

export(PackedScene) var npc

onready var timer : Timer = $Timer
onready var sprite : Sprite = $Sprite
onready var collision : CollisionShape2D = $CollisionShape2D

onready var npc_container : Node2D = $NPCContainer

func _ready():
	set_process(false)


func spawn() -> NPC:
	var new_npc = npc.instance()
	new_npc.init(nav, target, drop_spawner)
	
	return new_npc


func _process(_delta):
	if npc_container.get_child_count() == 0:
		set_process(false)
		queue_free()


func _on_Timer_timeout():
	npc_container.add_child(spawn())


func _on_Health_death():
	sprite.visible = false
	collision.queue_free()
	timer.stop()
	set_process(true)
