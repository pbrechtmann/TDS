extends WeaponAttachment

export(PackedScene) var bomb

var hits : Array = []

var final_modifiers : Dictionary = {}

func primary_attack(attack_mods : Dictionary) -> void:
	final_modifiers = create_final_mods(attack_mods)
	weapon.primary_attack(attack_mods)
	set_process(true)


func _process(_delta) -> void:
	if weapon.hits.size() < hits.size():
		set_process(false)
		hits.clear()
		return

	for hit in weapon.hits:
		if hits.has(hit):
			continue
		
		hits.append(hit)
		var bomb_instance : Projectile = bomb.instance()
		bomb_instance.init(hit.global_transform, Vector2.ZERO, final_modifiers, user)
		bomb_instance.fuse_time = 0.05
		add_child(bomb_instance)
