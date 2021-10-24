extends NPC
class_name Common

onready var weapon = $WeaponMelee

var speed = 300
var threshold = 75


func _ready():
	weapon.init(self)


func move():
	var path = nav.get_simple_path(global_position, target.global_position)
	var vec = global_position.direction_to(path[1]).normalized()
	
	move_and_slide(vec * speed)


func _physics_process(_delta):
	move()
	look_at(target.global_position)


func _process(_delta):
	if weapon.global_position.distance_to(target.global_position) <= threshold:
		weapon.try_primary_attack(energy_supply)
