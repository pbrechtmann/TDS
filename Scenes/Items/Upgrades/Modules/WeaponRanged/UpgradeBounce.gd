extends UpgradeModule


func apply_upgrade(to : Node2D) -> void:
	if to is WeaponRanged:
		if to.modifiers.has("bounce"):
			to.modifiers["bounce"] += 1
		else:
			to.modifiers["bounce"] = 1
