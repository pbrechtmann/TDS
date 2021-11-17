extends Weapon
class_name WeaponMelee

onready var area = $Area2D

var user : Entity


func init(u : Entity):
	user = u

func primary_attack() -> void:
	var targets = area.get_overlapping_bodies()
	for target in targets:
		if target is Entity and not target == user:
			target.get_damage(modifiers)
