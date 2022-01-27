extends WeaponMelee

export var attack_range : float = 100

func primary_attack(damage_mod : float) -> void:
	.primary_attack(damage_mod)
	tween.interpolate_property(self, "position:x", default_pos.x, default_pos.x + attack_range, attack_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(get_tree().create_timer(attack_duration), "timeout")
	attack_done()


func attack_done() -> void:
	tween.interpolate_property(self, "position:x", position.x, default_pos.x, attack_duration / 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	.attack_done()
