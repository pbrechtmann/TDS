extends UpgradeModule

var improvement_multipliers : float = 0.05

func apply_upgrade(to : Node2D) -> void:
	if to is Armor:
		if to.multipliers.has("damage"):
			to.multipliers["damage"] += to.multipliers["damage"] * improvement_multipliers
		else:
			to.multipliers["damage"] = improvement_multipliers
