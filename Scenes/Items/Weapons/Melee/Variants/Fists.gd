extends WeaponMelee


func primary_attack() -> void:
	.primary_attack()
	yield(get_tree().create_timer(attack_duration), "timeout")
	attack_done()
