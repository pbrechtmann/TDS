extends WeaponAttachment

export var duration : float = 1.5
export var tick_time : float = 0.1

onready var area : Area2D = $AreaOfEffect
onready var duration_timer : Timer = $Duration
onready var tick_timer : Timer = $Tick

onready var flame : Sprite = $Flame

var attack_mods : Dictionary
var done : bool = false

func primary_attack(attack_mods : Dictionary) -> void:
	flame.show()
	done = false
	self.attack_mods = attack_mods
	duration_timer.start(duration)
	tick_timer.start(tick_time)


func attack() -> void:
	for body in area.get_overlapping_bodies():
		if body is Entity:
			body.get_damage(create_final_mods(attack_mods), user)


func _on_Tick_timeout():
	attack()
	if not done:
		tick_timer.start(tick_time)


func _on_Duration_timeout():
	done = true
	flame.hide()
