extends WeaponAttachment

export(PackedScene) var projectile

export(Dictionary) var bleeding
export(Dictionary) var cold
export(Dictionary) var fire
export(Dictionary) var poison

onready var muzzle : Position2D = $Muzzle


func primary_attack(attack_mods : Dictionary) -> void:
	randomize()
	match randi() % 3:
		0:
			modifiers["bleeding"] = bleeding
		1:
			modifiers["cold"] = cold
		2:
			modifiers["fire"] = fire
		3:
			modifiers["poison"] = poison
	
	
	var new_projectile = projectile.instance()
	new_projectile.init(muzzle.global_transform, global_position.direction_to(muzzle.global_position), create_final_mods(attack_mods), user)
	
	add_child(new_projectile)
	modifiers.clear()
