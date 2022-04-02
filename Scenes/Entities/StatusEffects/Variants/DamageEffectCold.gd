extends DamageEffect


func start_effects() -> void:
	target.action_lock.add_action_lock()
	target.action_lock.add_move_lock()


func clear_effects() -> void:
	target.action_lock.remove_action_lock()
	target.action_lock.remove_move_lock()
