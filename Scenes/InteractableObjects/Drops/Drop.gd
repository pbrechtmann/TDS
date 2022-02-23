extends InteractableObject
class_name Drop


var texture : Texture


func _ready() -> void:
	if texture:
		sprite.set_texture(texture)


func activate(_user : Entity) -> void:
	queue_free()
