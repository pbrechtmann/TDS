extends WeaponAttachment

export var duration : float = 1.5
export var tick_time : float = 0.1

onready var duration_timer : Timer = $Duration
onready var tick_timer : Timer = $Tick

onready var laser : Sprite = $Laser
onready var ray : RayCast2D = $RayCast2D

var attack_mods : Dictionary
var done : bool = false

var hit : Node2D

func primary_attack(attack_mods : Dictionary) -> void:
	done = false
	set_process(true)
	ray.set_enabled(true)
	laser.show()
	self.attack_mods = attack_mods
	duration_timer.start(duration)
	tick_timer.start(tick_time)


func _process(_delta) -> void:
	if not ray.is_colliding():
		return
	
	var h = ray.get_collider()
	if h is Entity:
		if not hit:
			hit = h
		elif hit != h:
			hit = h
			attack()
	var laser_len = global_position.distance_to(ray.get_collision_point())
	laser.scale.x = laser_len


func attack() -> void:
	if not ray.is_colliding():
		return
	
	if is_instance_valid(hit):
		hit.get_damage(create_final_mods(attack_mods), user)


func _on_Tick_timeout():
	attack()
	if not done:
		tick_timer.start(tick_time)


func _on_Duration_timeout():
	done = true
	set_process(false)
	laser.hide()
	ray.set_enabled(false)
