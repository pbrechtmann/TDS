extends Node2D
class_name Projectile

var direction : Vector2 = Vector2.ZERO

var speed = 1000
var pierce = 0

var modifiers : Dictionary = {}


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


func _physics_process(delta) -> void:
	position += direction * delta * speed


func handle_pierce() -> bool:
	if pierce > 0:
		pierce -= 1
		return false
	return true


func _on_Area2D_body_entered(body : PhysicsBody2D) -> void:
	var done = true
	
	if body is Entity:
		body.get_damage(modifiers)
		done = handle_pierce()
		
	if done:
		queue_free()
