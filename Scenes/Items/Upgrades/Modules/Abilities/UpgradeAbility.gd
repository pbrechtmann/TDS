extends UpgradeModule
class_name UpgradeAbility

func apply_upgrade(to : Node2D) -> void:
	if not to is Ability:
		valid = false
