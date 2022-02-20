extends DamageEffect


func custom_process(delta) -> void:
	target.health.modify_value(-damage_per_second * delta)
