extends Ability

export var amount : float = 25


func activate_ability(user : Entity) -> void:
	user.health.heal(amount)
