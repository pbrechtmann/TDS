extends NPC
class_name Common

onready var weapon = $WeaponMelee

var speed = 300
var threshold = 75


func move():
	var path = nav.get_simple_path(global_position, target.global_position)
	if not path.empty():
		var vec = global_position.direction_to(path[1]).normalized()
		move_and_slide(vec * speed)
		look_at(global_position + vec)


func _physics_process(_delta):
	move()


func _process(_delta):
	if weapon.global_position.distance_to(target.global_position) <= threshold:
		weapon.try_primary_attack(energy_supply)
