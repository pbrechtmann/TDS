extends UpgradeCharacter

export var percent : float = 10.0

func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	var increase : float = to.health.modify_percent(percent)
	to.health.heal(increase)
