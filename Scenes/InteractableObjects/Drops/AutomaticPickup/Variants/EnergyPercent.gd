extends AutoDrop

export(float, 0, 1) var percentage = 0.25

func activate(user : Entity) -> void:
	var restore_amount = user.energy_supply.max_energy * percentage
	user.energy_supply.charge(restore_amount)
	.activate(user)
