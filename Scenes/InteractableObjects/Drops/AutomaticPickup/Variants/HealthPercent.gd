extends AutoDrop

export(float, 0, 1) var percentage = 0.25

func activate(user : Entity) -> void:
	var heal_amount = user.health.max_health * percentage
	user.health.heal(heal_amount)
	.activate(user)
