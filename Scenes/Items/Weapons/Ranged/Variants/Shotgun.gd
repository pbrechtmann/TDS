extends WeaponRanged
class_name WeaponShotgun


export(int) var bullet_num = 3
export(float) var max_spread_deg = 10


func primary_attack(attack_mods : Dictionary) -> void:
	for i in range(bullet_num):
		var new_projectile = projectile.instance()
		var dir = global_position.direction_to(muzzle.global_position)
		dir = dir.rotated(deg2rad(range_lerp(i, 0, bullet_num - 1, -max_spread_deg / 2, max_spread_deg)))
		new_projectile.init(muzzle.global_transform, dir, create_final_mods(attack_mods), user)
	
		add_child(new_projectile)


func get_dps() -> float:
	var shots_per_second = (1.0 / attack_delay) * bullet_num
	return modifiers["damage"] * shots_per_second


func new_dps(base : float) -> float:
	var shots_per_second = 1.0 / attack_delay * bullet_num
	var base_dmg = base / shots_per_second
	return base_dmg + rand_range(-base_dmg * 0.3, base_dmg * 0.1)
