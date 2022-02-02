extends Ability

export var dash_speed_mult : float = 2.0


func activate_ability(user : Entity) -> void:
	.activate_ability(user)
	user.statmods.set_speed(user.statmods.speed * dash_speed_mult)


func end_ability():
	user.statmods.reset_speed()
