extends UpgradeArmor

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)

	if not valid:
		return

	to.cold_resistance_amount += 1
	to.multipliers["cold"]["damage"] = pow(0.95, to.cold_resistance_amount)
	#multipliers["cold"]["damage"] *= 0.95
	#TODO: Split into init() and upgrade()
	to.multipliers["cold"]["duration"] = pow(0.95, to.cold_resistance_amount)
