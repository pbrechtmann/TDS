extends UpgradeModule

var improvement_multipliers : Dictionary = { 
										"dps": 0.05,
										"duration": 0.1
										}

func apply_upgrade(to : Node2D) -> void:
	if to is Armor:
		if to.multipliers.has("poison"):
			to.multipliers["poison"]["dps"] += to.multipliers["poison"]["dps"] * improvement_multipliers["dps"]
			to.multipliers["poison"]["duration"] += to.multipliers["poison"]["duration"] * improvement_multipliers["duration"]
		else:
			to.multipliers["poison"] = improvement_multipliers
