extends WeaponMelee


func primary_attack(damage_mod : float) -> void:
	.primary_attack(damage_mod)
	yield(get_tree().create_timer(attack_duration), "timeout")
	attack_done()
