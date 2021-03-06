extends UpgradeArmor

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)

	if not valid:
		return

	to.fire_resistance_amount += 1
	to.multipliers["fire"]["dps"] = pow(0.95, to.fire_resistance_amount)
	to.multipliers["fire"]["duration"] = pow(0.95, to.fire_resistance_amount)
