extends WeaponRanged
class_name WeaponSMG


export(int) var burst_num
export(float, 0, 1) var burst_delay


func primary_attack(attack_mods : Dictionary) -> void:
	final_modifiers = create_final_mods(attack_mods)
	for _i in range(burst_num):
		var new_projectile = projectile.instance()
		new_projectile.init(muzzle.global_transform, global_position.direction_to(muzzle.global_position), final_modifiers, user)
	
		add_child(new_projectile)
		yield(get_tree().create_timer(burst_delay), "timeout")
