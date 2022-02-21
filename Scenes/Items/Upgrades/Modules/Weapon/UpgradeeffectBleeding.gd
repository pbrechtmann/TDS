extends UpgradeModule


var bleeding : Dictionary = {
						"initial_damage" : 0,
						"dps" : 1,
						"duration" : 60,
						}


func apply_upgrade(to : Node2D) -> void:
	if to is Weapon:
		if to.modifiers.has("bleeding"):
			to.modifiers["bleeding"]["dps"] += bleeding["dps"] / 2
			to.modifiers["bleeding"]["duration"] += bleeding["duration"] / 2
		else:
			to.modifiers["bleeding"] = bleeding
