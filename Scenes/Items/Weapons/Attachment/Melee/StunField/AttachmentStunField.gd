extends WeaponAttachment

export var stun_duration : float = 1.5

onready var effect_area : Area2D = $EffectArea
onready var duration_timer : Timer = $Duration

var affected : Array = []


func primary_attack(_attack_mods : Dictionary) -> void:
	for body in effect_area.get_overlapping_bodies():
		if body is Entity:
			if body == user:
				continue
			
			if not affected.has(body):
				affected.append(body)
				body.action_lock.add_action_lock()
				body.action_lock.add_move_lock()
	duration_timer.start(stun_duration)


func _on_Duration_timeout():
	for body in affected:
		if is_instance_valid(body):
			body.action_lock.remove_action_lock()
			body.action_lock.remove_move_lock()
	affected.clear()
