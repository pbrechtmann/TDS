extends Drop
class_name AutoDrop

var target : Entity
var speed : float = 10


func _ready():
	set_process(false)


func activate(_user : Entity) -> void:
	queue_free()


func start(target : Entity) -> void:
	self.target = target
	set_process(true)


func _process(_delta):
	if is_instance_valid(target):
		global_position += global_position.direction_to(target.global_position) * speed


func _on_AutoDrop_body_entered(body):
	if body == target:
		activate(target)
