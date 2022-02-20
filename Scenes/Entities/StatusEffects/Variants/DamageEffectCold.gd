extends DamageEffect


func start_effects() -> void:
	target.statmods.set_speed(0)


func clear_effects() -> void:
	target.statmods.reset_speed()
