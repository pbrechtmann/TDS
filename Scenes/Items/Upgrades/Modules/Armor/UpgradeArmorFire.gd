extends UpgradeModule

var improvement_multipliers : Dictionary = { 
										"dps": 0.05,
										"duration": 0.1
										}

func apply_upgrade(to : Node2D) -> void:
	if to is Armor:
		if to.multipliers.has("fire"):
			to.multipliers["fire"]["dps"] += to.multipliers["fire"]["dps"] * improvement_multipliers["dps"]
			to.multipliers["fire"]["duration"] += to.multipliers["fire"]["duration"] * improvement_multipliers["duration"]
		else:
			to.multipliers["fire"] = improvement_multipliers
