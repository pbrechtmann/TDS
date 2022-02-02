extends WeaponMelee


func primary_attack(attack_mods : Dictionary) -> void:
	# TODO: animate hit
	yield(get_tree().create_timer(attack_duration), "timeout")
	.primary_attack(attack_mods)
	yield(get_tree().create_timer(0.01), "timeout")
	attack_done()


func attack_done() -> void:
	.attack_done()
	# TODO: animate wind-down
