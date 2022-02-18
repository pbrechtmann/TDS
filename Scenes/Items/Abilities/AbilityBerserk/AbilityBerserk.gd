extends Ability

export var damage_mult : float = 3.0
export var speed_mult : float = 1.2

export var damage_taken_per_second : float = 1.0

func activate_ability(user : Entity) -> void:
	.activate_ability(user)
	user.statmods.set_damage(damage_mult)
	user.statmods.set_speed(speed_mult)
	user.statmods.set_health_change(-damage_taken_per_second)


func end_ability() -> void:
	user.statmods.reset_damage()
	user.statmods.reset_speed()
	user.statmods.reset_health_change()
