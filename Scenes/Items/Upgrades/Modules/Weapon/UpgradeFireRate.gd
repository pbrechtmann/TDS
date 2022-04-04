extends UpgradeWeapon

export(float, 0.01, 1) var multiplier


func apply_upgrade(to : Node2D) -> void:
	.apply_upgrade(to)
	
	if not valid:
		return
	
	to.attack_delay *= multiplier
