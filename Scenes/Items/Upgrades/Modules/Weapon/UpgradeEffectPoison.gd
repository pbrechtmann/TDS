extends UpgradeWeapon


var poison : Dictionary = {
						"initial_damage" : 10,
						"dps" : 0.5,
						"duration" : 20,
						}


func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	if to.modifiers.has("poison"):
		to.modifiers["poison"]["initial_damage"] += poison["initial_damage"] / 2
		to.modifiers["poison"]["duration"] += poison["duration"] / 2
	else:
		to.modifiers["poison"] = poison
