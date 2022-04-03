extends UpgradeModule

func apply_upgrade(to : Node2D) -> void:
	if not to is Armor:
		return
	to.dmg_resistance_amount += 1
	to.multipliers["damage"] = pow(0.95, to.dmg_resistance_amount)
