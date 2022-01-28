extends Ability

export var lifesteal_percent : float = 5


func activate_ability(user : Entity) -> void:
	.activate_ability(user)
	user.statmods.set_lifesteal(lifesteal_percent / 100)


func end_ability() -> void:
	user.statmods.reset_lifesteal()
