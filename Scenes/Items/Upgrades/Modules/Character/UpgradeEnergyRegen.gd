extends UpgradeCharacter

export var amount : float = 0.5

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	to.statmods.set_energy_change_default(to.statmods.energy_change_per_second_default + amount)
