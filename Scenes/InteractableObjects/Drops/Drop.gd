extends InteractableObject
class_name Drop


func activate(_user : Entity) -> void:
	queue_free()
