extends UpgradeModule

func apply_upgrade(to : Node2D) -> void:
	if to is Armor:
		to.upgrade_fire_resistance()
