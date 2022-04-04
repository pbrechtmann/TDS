extends UpgradeModule
class_name UpgradeWeaponMelee

func apply_upgrade(to : Node2D) -> void:
	if not to is WeaponMelee:
		valid = false
