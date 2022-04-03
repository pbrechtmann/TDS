extends UpgradeModule

func apply_upgrade(to : Node2D) -> void:
	if not to is Armor:
		return
	to.poison_resistance_amount += 1
	to.multipliers["poison"]["dps"] = pow(0.95, to.poison_resistance_amount)
	to.multipliers["poison"]["duration"] = pow(0.95, to.poison_resistance_amount)
