extends WeaponMelee

export var attack_range : float = 350
export var arc_radius : float = 150


func primary_attack(attack_mods : Dictionary) -> void:
	tween.interpolate_property(self, "position:x", default_pos.x, default_pos.x + attack_range, (attack_duration / 3.0) * 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_method(self, "arc", 0, PI, (attack_duration / 3.0) * 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer((attack_duration / 3.0) * 2), "timeout")
	
	.primary_attack(attack_mods)
	
	tween.interpolate_property(self, "position:x", position.x, default_pos.x, attack_duration / 3.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(attack_duration / 3.0), "timeout")
	
	attack_done()


func attack_done() -> void:
	.attack_done()


func arc(progress : float) -> void:
	position.y = sin(progress) * arc_radius
