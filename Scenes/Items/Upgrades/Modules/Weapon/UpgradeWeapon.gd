extends UpgradeModule
class_name UpgradeWeapon

func apply_upgrade(to : Node2D) -> void:
	if not to is Weapon:
		valid = false
