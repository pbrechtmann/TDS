extends Node
class_name StatMods

var speed : float = 1.0
var speed_default : float = 1.0

var health_change_per_second : float = 0.0
var health_change_per_second_default : float = 0.0

var energy_change_per_second : float = 10.0
var energy_change_per_second_default : float = 10.0


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
	if attack_mods["damage"] == attack_mods_default["damage"]:
		set_damage(to)
	attack_mods_default["damage"] = to

func reset_damage() -> void:
	attack_mods["damage"] = attack_mods_default["damage"]


func set_lifesteal(to : float) -> void:
	attack_mods["lifesteal"] = to

func set_lifesteal_default(to : float) -> void:
	if attack_mods["lifesteal"] == attack_mods_default["lifesteal"]:
		set_lifesteal(to)
	attack_mods_default["lifesteal"] = to

func reset_lifesteal() -> void:
	attack_mods["lifesteal"] = attack_mods_default["lifesteal"]


func set_speed(to : float) -> void:
	speed = to

func set_speed_default(to : float) -> void:
	if speed == speed_default:
		set_speed(to)
	speed_default = to

func reset_speed() -> void:
	speed = speed_default


func set_health_change(to : float) -> void:
	health_change_per_second = to

func set_health_change_default(to : float) -> void:
	if health_change_per_second == health_change_per_second_default:
		set_health_change(to)
	health_change_per_second_default = to

func reset_health_change() -> void:
	health_change_per_second = health_change_per_second_default


func set_energy_change(to : float) -> void:
	energy_change_per_second = to

func set_energy_change_default(to : float) -> void:
	if energy_change_per_second == energy_change_per_second_default:
		set_energy_change(to)
	energy_change_per_second_default = to

func reset_energy_change() -> void:
	energy_change_per_second = energy_change_per_second_default
