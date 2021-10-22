extends Weapon
class_name WeaponMelee

onready var area = $Area2D

export(float) var damage = 25
export(float, 0, 1) var crit_chance = 0.1
export(float) var crit_multiplier = 2

var user : Entity

func init(u : Entity):
	user = u

func primary_attack() -> void:
	var targets = area.get_overlapping_bodies()
	for target in targets:
		if target is Entity and not target == user:
			target.health.damage(damage * (1.0 if rand_range(0, 1) > crit_chance else crit_multiplier))
