extends CanvasLayer
class_name UI


var player : Player = null


onready var energy_bar : TextureProgress = $Control/MarginContainer/HBoxContainer/VBoxContainer/Energy
onready var health_bar : TextureProgress = $Control/MarginContainer/HBoxContainer/VBoxContainer/Health

onready var ability_cooldown : TextureProgress = $Control/MarginContainer/HBoxContainer/Ability
onready var dash_cooldown


func init(player : Player):
	self.player = player
	
	if player.health.connect("max_changed", self, "_on_Health_max_changed") != OK:
		printerr("Connecting max changed from Health to UI failed")
	if player.energy_supply.connect("max_changed", self, "_on_Energy_max_changed") != OK:
		printerr("Connecting max changed from EnergySupply to UI failed")
	
	health_bar.max_value = player.health.max_health
	energy_bar.max_value = player.energy_supply.max_energy
	
	ability_cooldown.max_value = player.ability.ability_delay


func _process(_delta):
	if not is_instance_valid(player):
		return
	health_bar.value = player.health.current_health
	energy_bar.value = player.energy_supply.current_energy
	
	ability_cooldown.value = ability_cooldown.max_value - player.ability.cooldown_timer.get_time_left()


func _on_Health_max_changed(new_value : float) -> void:
	health_bar.max_value = new_value


func _on_Energy_max_changed(new_value : float) -> void:
	energy_bar.max_value = new_value


func _on_Ability_delay_changed(new_value : float) -> void:
	ability_cooldown.max_value = new_value
