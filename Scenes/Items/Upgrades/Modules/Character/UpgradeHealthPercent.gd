extends UpgradeModule

export var percent : float = 10.0

func apply_upgrade(to : Node2D) -> void:
	if to is Entity:
		to.health.modify_percent(percent)
