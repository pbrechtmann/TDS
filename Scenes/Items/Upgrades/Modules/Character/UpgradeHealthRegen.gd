extends UpgradeCharacter

export var amount : float = 0.25

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	to.statmods.set_health_change_default(to.statmods.health_change_per_second_default + amount)
