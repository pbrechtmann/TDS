extends Node2D
class_name Projectile

var direction : Vector2 = Vector2.ZERO

var speed : float = 1000

var pierce : int = 0
var bounce : int = 0

var modifiers : Dictionary = {}
var source : Node2D

onready var collision_ray : RayCast2D = $RayCast2D


func init(muzzle_transform : Transform2D, dir : Vector2, modifiers : Dictionary, source : Node2D) -> void:
	set_as_toplevel(true)
	direction = dir
	global_transform = muzzle_transform
	
	self.source = source
	self.modifiers = modifiers
	for key in modifiers:
		match key:
			"speed":
				speed = modifiers[key]
			"pierce":
				pierce = modifiers[key]
			"bounce":
				bounce = modifiers[key]


func _physics_process(delta) -> void:
	position += direction * delta * speed


func handle_pierce() -> bool:
	if pierce > 0:
		pierce -= 1
		return false
	return true


func handle_bounce() -> bool:
	if bounce > 0:
		bounce -= 1
		
		var normal = Vector2.ZERO
		
		for i in range(1, 100):
			if collision_ray.is_colliding():
				normal = collision_ray.get_collision_normal()
				break
			else:
				collision_ray.cast_to.y = lerp(-10, 10, i * 0.01)
				collision_ray.force_raycast_update()
		
		normal.normalized()
		
		direction = direction.bounce(normal)
		rotation = direction.angle()
		return false
	return true


func impact(body : PhysicsBody2D) -> void:
	var done = true
	
	if body is Entity:
		body.get_damage(modifiers, source)
		done = handle_pierce()
	else:
		done = handle_bounce()
		
	if done:
		queue_free()


func _on_Area2D_body_entered(body : PhysicsBody2D) -> void:
	impact(body)
