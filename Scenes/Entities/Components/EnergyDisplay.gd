extends Sprite
class_name EnergyDisplay

var display_material = preload("res://Assets/Shaders/EnergyDisplay.material").duplicate()


func _ready():
	material = display_material


func show_energy(energy_supply):
	var energy_value = energy_supply.get_energy_percent()
	display_material.set_shader_param("fill_ratio", energy_value)
