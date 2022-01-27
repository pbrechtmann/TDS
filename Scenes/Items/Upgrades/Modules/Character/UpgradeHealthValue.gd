extends UpgradeModule

export var amount : float = 10.0

func apply_upgrade(to : Node2D) -> void:
	if to is Entity:
		to.health.modify_value(amount)
