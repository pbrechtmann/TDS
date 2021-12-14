extends CanvasLayer
class_name UI


var player : Player = null

onready var margin_container : MarginContainer = $Control/MarginContainer

onready var energy_bar : TextureProgress = $Control/MarginContainer/HBoxContainer/VBoxContainer/Energy
onready var health_bar : TextureProgress = $Control/MarginContainer/HBoxContainer/VBoxContainer/Health

onready var ability_cooldown : TextureProgress = $Control/MarginContainer/HBoxContainer/Ability
onready var dash_cooldown

onready var melee_display : TextureRect = $Control/MarginContainer/HBoxContainer/WeaponMelee/Display
onready var ranged_display : TextureRect = $Control/MarginContainer/HBoxContainer/WeaponRanged/Display


func _ready():
	margin_container.margin_top = OS.get_window_size().y - 128 + margin_container.margin_bottom


func init(player : Player):
	self.player = player
	
	if player.health.connect("max_changed", self, "_on_Health_max_changed") != OK:
		printerr("Connecting max changed from Health to UI failed")
	if player.energy_supply.connect("max_changed", self, "_on_Energy_max_changed") != OK:
		printerr("Connecting max changed from EnergySupply to UI failed")
	if player.connect("weapon_changed", self, "_on_Player_weapon_changed") != OK:
		printerr("Connecting weapon changed from Player to UI failed")
	if player.connect("weapon_switched", self, "_on_Player_weapon_switched") != OK:
		printerr("Connecting weapon switched from Player to UI failed")
	
	health_bar.max_value = player.health.max_health
	energy_bar.max_value = player.energy_supply.max_energy
	
	ability_cooldown.max_value = player.ability.ability_delay

	melee_display.texture = player.weapon_melee.icon
	ranged_display.texture = player.weapon_ranged.icon


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


func _on_Player_weapon_changed() -> void:
	melee_display.texture = player.weapon_melee.icon
	ranged_display.texture = player.weapon_ranged.icon


func _on_Player_weapon_switched(switched_to : String) -> void:
	if switched_to == "melee":
		pass
	else:
		pass
