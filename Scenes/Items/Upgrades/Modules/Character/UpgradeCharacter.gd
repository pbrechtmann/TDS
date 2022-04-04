extends UpgradeModule
class_name UpgradeCharacter

func apply_upgrade(to : Node2D) -> void:
	if not to is Entity:
		valid = false
