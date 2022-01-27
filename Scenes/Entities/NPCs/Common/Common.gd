extends NPC
class_name Common

onready var weapon = $Fists

var speed = 300
var threshold = 75


func _ready() -> void:
	weapon.init(self)


func move() -> void:
	var path = nav.get_simple_path(global_position, target.global_position)
	if not path.empty():
		var vec = global_position.direction_to(path[1]).normalized()
		vec = move_and_slide(vec * speed)
		look_at(global_position + vec)


func _physics_process(_delta) -> void:
	move()


func _process(_delta) -> void: 
	if weapon.global_position.distance_to(target.global_position) <= threshold:
		weapon.try_primary_attack(energy_supply)


func _on_Health_death() -> void:
	if not dead:
		dead = true
		drop_spawner.spawn_drop(1, global_position, 1, 3, true)
		._on_Health_death()
