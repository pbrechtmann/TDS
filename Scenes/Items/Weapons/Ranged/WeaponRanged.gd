extends Weapon
class_name WeaponRanged

export(PackedScene) var projectile

onready var muzzle : Position2D = $Muzzle


func primary_attack() -> void:
	var new_projectile = projectile.instance()
	new_projectile.init(muzzle.global_transform, global_position.direction_to(muzzle.global_position), modifiers)
	
	add_child(new_projectile)
