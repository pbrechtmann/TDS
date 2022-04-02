extends Projectile

export var fuse_time : float = 1.5
export var hit_range : float = 250

export var ignore_user : bool = false

onready var fuse : Timer = $Fuse

onready var hit_area : Area2D = $HitArea
onready var hit_shape : CollisionShape2D = $HitArea/CollisionShape2D

var min_intensity : float = 0.25


func _ready():
	hit_shape.shape.radius = hit_range
	fuse.start(fuse_time)


func impact(body : PhysicsBody2D) -> void:
	var done = true
	
	if body is Entity:
		body.get_damage(modifiers, source)
	else:
		done = handle_bounce()

	if done:
		explode()


func explode() -> void:
	for body in hit_area.get_overlapping_bodies():
		if body is Entity:
			if ignore_user and body == source:
				continue
			var distance = global_position.distance_to(body.global_position)
			var falloff_intensity = max(inverse_lerp(0, hit_range, distance), min_intensity)
			body.get_damage(damage_falloff(modifiers, falloff_intensity), source)
	queue_free()


func damage_falloff(base : Dictionary, intensity : float) -> Dictionary:
	var new_modifiers : Dictionary = base
	for key in new_modifiers:
		if typeof(new_modifiers[key]) == TYPE_REAL:
			new_modifiers[key] *= intensity
		if typeof(new_modifiers[key]) == TYPE_DICTIONARY:
			new_modifiers[key] = damage_falloff(new_modifiers[key], intensity)
	
	return new_modifiers


func _on_Fuse_timeout():
	explode()
