extends WeaponMelee


func primary_attack(damage_mod : float) -> void:
	# TODO: animate hit
	yield(get_tree().create_timer(attack_duration), "timeout")
	.primary_attack(damage_mod)
	yield(get_tree().create_timer(0.01), "timeout")
	attack_done()


func attack_done() -> void:
	.attack_done()
	# TODO: animate wind-down
