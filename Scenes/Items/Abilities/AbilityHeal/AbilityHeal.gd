extends Ability

export var amount : float = 25


func activate_ability(user : Entity) -> void:
	.activate_ability(user)
	user.health.heal(amount)
