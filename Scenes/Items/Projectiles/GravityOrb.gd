extends Projectile

export var gravity_force : float = 500
export var lifetime : float = 2

onready var effect_area : Area2D = $EffectArea
onready var lifetime_timer : Timer = $Lifetime

var affected : Array = []

func _ready() -> void:
	lifetime_timer.start(lifetime)


func _physics_process(_delta : float) -> void:
	for body in effect_area.get_overlapping_bodies():
		if body is Entity:
			if body == source or body is Spawner:
				continue
			if not body.action_lock.is_move_locked():
				affected.append(body)
				body.action_lock.add_move_lock()
	for body in affected:
		body.move_and_slide(body.global_position.direction_to(global_position) * gravity_force)


func impact(_body : PhysicsBody2D) -> void:
	speed = 0


func _on_Lifetime_timeout():
	for body in affected:
		if is_instance_valid(body):
			body.action_lock.remove_move_lock()
	queue_free()
