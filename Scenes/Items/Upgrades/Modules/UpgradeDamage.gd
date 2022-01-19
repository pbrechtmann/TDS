extends UpgradeModule

export(float, 1, 100) var increase_mult : float


func apply_upgrade(to : Node2D) -> void:
	if to is Weapon:
		to.modifiers["damage"] *= increase_mult
