extends UpgradeArmor

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)

	if not valid:
		return

	to.dmg_resistance_amount += 1
	to.multipliers["damage"] = pow(0.95, to.dmg_resistance_amount)
