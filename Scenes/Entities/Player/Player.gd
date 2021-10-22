extends Entity

export(float) var speed = 1000
export(float) var dash_force = 4

onready var weapon : Weapon = $WeaponRanged
onready var energy_display : EnergyDisplay = $EnergyDisplay


func move():
	var delta_vec = Vector2.ZERO
	delta_vec.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	delta_vec.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	delta_vec = delta_vec.normalized()
	var dash : float = dash_force if Input.is_action_just_pressed("dash") else 1.0
	move_and_slide(delta_vec * speed * dash)


func _physics_process(_delta):
	move()
	look_at(get_global_mouse_position())


func _process(_delta):
	energy_display.show_energy(energy_supply)
	
	if Input.is_action_pressed("attack_primary"):
		weapon.try_primary_attack(energy_supply)
