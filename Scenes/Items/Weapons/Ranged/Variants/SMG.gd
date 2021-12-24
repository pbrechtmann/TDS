extends WeaponRanged
class_name WeaponSMG


export(int) var burst_num
export(float, 0, 1) var burst_delay


func primary_attack() -> void:
	for _i in range(burst_num):
		var new_projectile = projectile.instance()
		new_projectile.init(muzzle.global_transform, global_position.direction_to(muzzle.global_position), modifiers)
	
		add_child(new_projectile)
		yield(get_tree().create_timer(burst_delay), "timeout")
