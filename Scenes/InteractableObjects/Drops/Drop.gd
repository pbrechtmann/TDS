extends InteractableObject
class_name Drop


func activate(user : Entity) -> void:
	queue_free()
