extends UpgradeModule

export var percent : float = 10.0

func apply_upgrade(to : Node2D) -> void:
	if to is Entity:
		var increase : float = to.energy_supply.modify_percent(percent)
		to.energy_supply.charge(increase)