extends UpgradeModule

var improvement_multipliers : Dictionary = { 
										"damage": 0.05,
										"duration": 0.1
										}

func apply_upgrade(to : Node2D) -> void:
	if to is Armor:
		if to.multipliers.has("cold"):
			to.multipliers["cold"]["damage"] += to.multipliers["cold"]["damage"] * improvement_multipliers["damage"]
			to.multipliers["cold"]["duration"] += to.multipliers["cold"]["duration"] * improvement_multipliers["duration"]
		else:
			to.multipliers["cold"] = improvement_multipliers
