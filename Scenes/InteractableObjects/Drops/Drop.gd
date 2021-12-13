extends InteractableObject
class_name Drop

export var scene : PackedScene

func activate(user : Entity) -> void:
	user.pickup_weapon(scene)
	queue_free()
