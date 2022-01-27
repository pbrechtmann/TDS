extends UpgradeModule

export(float, 0.01, 1) var multiplier

func apply_upgrade(to : Node2D) -> void:
	if to is Ability:
		to.ability_cost *= multiplier
