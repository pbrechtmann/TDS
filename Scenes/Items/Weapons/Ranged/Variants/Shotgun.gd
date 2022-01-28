extends WeaponRanged
class_name WeaponShotgun


export(int) var bullet_num = 3
export(float) var max_spread_deg = 10


func primary_attack(attack_mods : Dictionary) -> void:
	final_modifiers = create_final_mods(attack_mods)
	for i in range(bullet_num):
		var new_projectile = projectile.instance()
		var dir = global_position.direction_to(muzzle.global_position)
		dir = dir.rotated(deg2rad(range_lerp(i, 0, bullet_num - 1, -max_spread_deg / 2, max_spread_deg)))
		new_projectile.init(muzzle.global_transform, dir, final_modifiers, user)
	
		add_child(new_projectile)
