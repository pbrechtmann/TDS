extends Weapon
class_name WeaponRanged

export(PackedScene) var projectile

onready var muzzle : Position2D = $Muzzle


func primary_attack(damage_mod : float) -> void:
	var new_projectile = projectile.instance()
	if modifiers.has("damage"):
		modifiers["damage"] *= damage_mod
	new_projectile.init(muzzle.global_transform, global_position.direction_to(muzzle.global_position), modifiers)
	
	add_child(new_projectile)
