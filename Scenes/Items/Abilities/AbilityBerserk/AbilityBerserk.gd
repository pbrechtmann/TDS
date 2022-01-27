extends Ability

export var damage_mult : float = 3.0
export var speed_mult : float = 1.2

export var damage_taken_per_second : float = 1.0

func activate_ability(user : Entity) -> void:
	.activate_ability(user)
	user.statmods.set_damage(damage_mult)
	user.statmods.set_speed(speed_mult)


func end_ability():
	user.statmods.reset_damage()
	user.statmods.reset_speed()


func custom_process(delta) -> void:
	user.health.damage(damage_taken_per_second * delta)
