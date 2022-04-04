extends UpgradeModule
class_name UpgradeWeaponRanged

func apply_upgrade(to : Node2D) -> void:
	if not to is WeaponRanged:
		valid = false
