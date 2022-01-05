extends AutoDrop

export var energy_restore : float = 10

func activate(user : Entity) -> void:
	user.energy_supply.charge(energy_restore)
	.activate(user)
