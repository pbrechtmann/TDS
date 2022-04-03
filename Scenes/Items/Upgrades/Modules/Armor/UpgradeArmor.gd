extends UpgradeModule
class_name UpgradeArmor

func apply_upgrade(to : Node2D) -> void:
	if not to is Armor:
		valid = false
