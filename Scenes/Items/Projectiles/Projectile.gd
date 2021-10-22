extends Node2D
class_name Projectile

var direction : Vector2 = Vector2.ZERO

var speed = 1000
var damage = 50
var crit_chance = 0
var crit_multiplier = 2
var pierce = 0


func init(muzzle_transform : Transform2D, dir : Vector2, modifiers : Dictionary) -> void:
	direction = dir
	global_transform = muzzle_transform
	
	for key in modifiers:
		match key:
			"damage":
				damage = modifiers[key]
			"speed":
				speed = modifiers[key]
			"crit_chance":
				crit_chance = modifiers[key]
			"crit_multiplier":
				crit_multiplier = modifiers[key]
			"pierce":
				pierce = modifiers[key]


func _physics_process(delta) -> void:
	position += direction * delta * speed


func handle_damage(body : Entity) -> void:
	body.health.damage(damage * (1.0 if rand_range(0, 1) > crit_chance else crit_multiplier))
	

func handle_pierce() -> bool:
	if pierce > 0:
		pierce -= 1
		return false
	return true
	
	
func _on_Area2D_body_entered(body : PhysicsBody2D) -> void:
	var done = true
	
	if body is Entity:
		handle_damage(body)
		done = handle_pierce()
		
	if done:
		queue_free()
