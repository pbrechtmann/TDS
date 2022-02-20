extends DamageEffect


func custom_process(delta) -> void:
	target.health.damage(damage_per_second * delta)
