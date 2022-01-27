extends UpgradeModule


func apply_upgrade(to : Node2D) -> void:
	if to is WeaponRanged:
		if to.modifiers.has("pierce"):
			to.modifiers["pierce"] += 1
		else:
			to.modifiers["pierce"] = 1
