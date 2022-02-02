extends Node
class_name StatMods

var speed : float = 1.0
var speed_default : float = 1.0


var attack_mods : Dictionary = {
								"damage" : 1.0,
								"lifesteal" : 0.0
								}

var attack_mods_default : Dictionary = {
										"damage" : 1.0,
										"lifesteal" : 0.0
										}


func set_damage(to : float) -> void:
	attack_mods["damage"] = to

func set_damage_default(to : float) -> void:
	attack_mods_default["damage"] = to
	set_damage(to)

func reset_damage() -> void:
	attack_mods["damage"] = attack_mods_default["damage"]


func set_lifesteal(to : float) -> void:
	attack_mods["lifesteal"] = to

func set_lifesteal_default(to : float) -> void:
	attack_mods_default["lifesteal"] = to
	set_lifesteal(to)

func reset_lifesteal() -> void:
	attack_mods["lifesteal"] = attack_mods_default["lifesteal"]


func set_speed(to : float) -> void:
	speed = to

func set_speed_default(to : float) -> void:
	speed_default = to
	set_speed(to)

func reset_speed() -> void:
	speed = speed_default
