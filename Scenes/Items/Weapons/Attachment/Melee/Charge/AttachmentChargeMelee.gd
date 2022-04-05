extends WeaponAttachment

export var charge_time : float = 1.5

onready var charge_timer : Timer = $ChargeTimer

var attack_mods : Dictionary = {}

func primary_attack(attack_mods : Dictionary) -> void:
	self.attack_mods = attack_mods.duplicate(true)
	user.action_lock.add_action_lock()
	charge_timer.start(charge_time)


func _on_ChargeTimer_timeout():
	user.action_lock.remove_action_lock()
	attack_mods["damage"] *= 2
	weapon.primary_attack(attack_mods)
