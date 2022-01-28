extends Weapon
class_name WeaponMelee

export var attack_duration : float = 0.1


onready var area = $Area2D
onready var tween = $Tween

var default_pos : Vector2 = Vector2.ZERO
var default_rotation : float = 0

var hits : Array = []


func _ready() -> void:
	default_pos += position
	default_rotation += rotation_degrees
	set_process(false)


func primary_attack(attack_mods : Dictionary) -> void:
	final_modifiers = create_final_mods(attack_mods)
	set_process(true)


func attack_done() -> void:
	set_process(false)
	hits.clear()


func _process(_delta) -> void:
	var targets = area.get_overlapping_bodies()
	for target in targets:
		if target is Entity and not target == user and not hits.has(target):
			hits.append(target)
			target.get_damage(final_modifiers, user)
