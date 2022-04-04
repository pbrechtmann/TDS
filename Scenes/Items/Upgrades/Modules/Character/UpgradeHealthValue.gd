extends UpgradeCharacter

export var amount : float = 10.0

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	to.health.modify_value(amount)
	to.health.heal(amount)
