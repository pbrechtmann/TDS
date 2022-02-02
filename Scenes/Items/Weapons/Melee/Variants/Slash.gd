extends WeaponMelee

export var attack_rotation : float = 90


func primary_attack(attack_mods : Dictionary) -> void:
	.primary_attack(attack_mods)
	tween.interpolate_property(self, "rotation_degrees", default_rotation, default_rotation - attack_rotation, attack_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(attack_duration), "timeout")
	attack_done()


func attack_done() -> void:
	tween.interpolate_property(self, "rotation_degrees", rotation_degrees, default_rotation, attack_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	.attack_done()

