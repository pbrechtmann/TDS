extends Node2D
class_name Projectile

var direction : Vector2 = Vector2.ZERO

var speed : float = 1000

var pierce : int = 0
var bounce : int = 0

var modifiers : Dictionary = {}

onready var collision_ray : RayCast2D = $RayCast2D


func init(muzzle_transform : Transform2D, dir : Vector2, modifiers : Dictionary) -> void:
	set_as_toplevel(true)
	direction = dir
	global_transform = muzzle_transform
	
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
		direction = direction.bounce(collision_ray.get_collision_normal().normalized())
		rotation = direction.angle()
		return false
	return true


func _on_Area2D_body_entered(body : PhysicsBody2D) -> void:
	var done = true
	
	if body is Entity:
		body.get_damage(modifiers)
		done = handle_pierce()
	else:
		done = handle_bounce()
		
	if done:
		queue_free()
