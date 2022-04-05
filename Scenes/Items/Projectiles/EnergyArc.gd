extends Projectile

var arc_shader = preload("res://Assets/Shaders/EngeryArc.material").duplicate()

export var lifetime : float = 1.5

export(Color) var bleeding
export(Color) var cold
export(Color) var fire
export(Color) var poison

onready var sprite : Sprite = $Sprite
onready var tween : Tween = $Tween
onready var timer : Timer = $Timer


func _ready() -> void:
	var _t = tween.interpolate_property(self, "scale", get_scale(), get_scale() * 10, 0.75, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_t = tween.start()
	timer.start(lifetime)
	
	sprite.set_material(arc_shader)
	
	if modifiers.has("bleeding"):
		arc_shader.set_shader_param("color", bleeding)
	elif modifiers.has("cold"):
		arc_shader.set_shader_param("color", cold)
	elif modifiers.has("fire"):
		arc_shader.set_shader_param("color", fire)
	elif modifiers.has("poison"):
		arc_shader.set_shader_param("color", poison)


func impact(body : PhysicsBody2D) -> void:
	if body is Entity:
		body.get_damage(modifiers, source)


func _on_Timer_timeout():
	queue_free()
