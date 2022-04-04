extends UpgradeWeapon


var cold : Dictionary = {
						"initial_damage" : 5,
						"dps" : 0.1,
						"duration" : 2,
						}


func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	if to.modifiers.has("cold"):
		to.modifiers["cold"]["initial_damage"] += cold["initial_damage"]
		to.modifiers["cold"]["duration"] += cold["duration"] / 2
	else:
		to.modifiers["cold"] = cold
