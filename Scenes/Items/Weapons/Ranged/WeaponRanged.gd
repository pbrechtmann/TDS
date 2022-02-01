extends Weapon
class_name WeaponRanged

export(PackedScene) var projectile

onready var muzzle : Position2D = $Muzzle


func primary_attack(attack_mods : Dictionary) -> void:
	var new_projectile = projectile.instance()
	new_projectile.init(muzzle.global_transform, global_position.direction_to(muzzle.global_position), create_final_mods(attack_mods), user)
	
	add_child(new_projectile)
