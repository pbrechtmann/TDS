extends Armor
class_name BasicArmor

export(float) var multiplier = 0.75


func modify_damage(damage : float):
	return multiplier * damage
