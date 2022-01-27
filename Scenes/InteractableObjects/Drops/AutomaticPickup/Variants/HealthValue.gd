extends AutoDrop

export var heal_amount : float = 10

func activate(user : Entity) -> void:
	user.health.heal(heal_amount)
	.activate(user)
