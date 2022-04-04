extends UpgradeWeaponRanged


func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	if to.modifiers.has("pierce"):
		to.modifiers["pierce"] += 1
	else:
		to.modifiers["pierce"] = 1
