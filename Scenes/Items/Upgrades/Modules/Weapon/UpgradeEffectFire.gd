extends UpgradeWeapon

var fire : Dictionary = {
						"initial_damage" : 0.5,
						"dps" : 0.5,
						"duration" : 1,
						}

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	if to.modifiers.has("fire"):
		to.modifiers["fire"]["dps"] += fire["dps"]
		to.modifiers["fire"]["duration"] += fire["duration"] / 2
	else:
		to.modifiers["fire"] = fire
