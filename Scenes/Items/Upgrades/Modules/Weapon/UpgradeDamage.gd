extends UpgradeWeapon

export(float, 1, 100) var increase_mult : float


func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	to.modifiers["damage"] *= increase_mult
