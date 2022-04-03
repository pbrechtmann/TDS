extends Projectile

export var fuse_time : float = 1.5
export var hit_range : float = 250

export var ignore_user : bool = false

onready var fuse : Timer = $Fuse

var hit_shape : CircleShape2D
var min_intensity : float = 0.25


func _ready():
	hit_shape = CircleShape2D.new()
	hit_shape.set_radius(hit_range)
	fuse.start(fuse_time)


func impact(body : PhysicsBody2D) -> void:
	var done = true
	
	if body is Entity:
		explode()
	else:
		done = handle_bounce()
	
	if done:
		explode()


func explode() -> void:
	var query : Physics2DShapeQueryParameters = Physics2DShapeQueryParameters.new()
	query.set_shape(hit_shape)
	query.set_collision_layer(6)
	query.set_transform(global_transform)
	var space_state : Physics2DDirectSpaceState = get_world_2d().direct_space_state
	var hits : Array = space_state.intersect_shape(query)
	
	for hit in hits:
		var body : PhysicsBody2D = hit.collider
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
