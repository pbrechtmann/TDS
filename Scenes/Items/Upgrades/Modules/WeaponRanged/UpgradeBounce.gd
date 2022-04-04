extends UpgradeWeaponRanged


func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	if to.modifiers.has("bounce"):
		to.modifiers["bounce"] += 1
	else:
		to.modifiers["bounce"] = 1
