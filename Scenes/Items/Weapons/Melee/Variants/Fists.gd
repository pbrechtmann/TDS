extends WeaponMelee


func primary_attack(attack_mods : Dictionary) -> void:
	.primary_attack(attack_mods)
	yield(get_tree().create_timer(attack_duration), "timeout")
	attack_done()
