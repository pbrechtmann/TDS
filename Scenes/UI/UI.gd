extends CanvasLayer
class_name UI


var player : Player = null

onready var margin_container : MarginContainer = $Control/MarginContainer

onready var energy_bar : TextureProgress = $Control/MarginContainer/HBoxContainer/VBoxContainer/Energy
onready var health_bar : TextureProgress = $Control/MarginContainer/HBoxContainer/VBoxContainer/Health

onready var ability_cooldown : TextureProgress = $Control/MarginContainer/HBoxContainer/Ability
onready var ability_character_cooldown : TextureProgress = $Control/MarginContainer/HBoxContainer/AbilityCharacter

onready var melee_display : TextureRect = $Control/MarginContainer/HBoxContainer/WeaponMelee/Display
onready var ranged_display : TextureRect = $Control/MarginContainer/HBoxContainer/WeaponRanged/Display


func _ready() -> void:
	var window_size : Vector2 = OS.get_window_size()
	margin_container.margin_bottom = window_size.y / -108 # 10 pixel margin for FullHD
	margin_container.margin_top = window_size.y - 128 + margin_container.margin_bottom
	
	margin_container.margin_left = (window_size.x / 192) * 2 # 20 pixel margin for FullHD
	margin_container.margin_right = -margin_container.margin_left


func init(player : Player) -> void:
	self.player = player
	
	if player.health.connect("max_changed", self, "_on_Health_max_changed") != OK:
		printerr("Connecting max changed from Health to UI failed")
	if player.energy_supply.connect("max_changed", self, "_on_Energy_max_changed") != OK:
		printerr("Connecting max changed from EnergySupply to UI failed")
	if player.connect("ability_changed", self, "_on_Player_ability_changed") != OK:
		printerr("Connecting ability changed from Player to UI failed")
	if player.connect("weapon_changed", self, "_on_Player_weapon_changed") != OK:
		printerr("Connecting weapon changed from Player to UI failed")
	if player.connect("weapon_switched", self, "_on_Player_weapon_switched") != OK:
		printerr("Connecting weapon switched from Player to UI failed")
	
	health_bar.max_value = player.health.max_health
	energy_bar.max_value = player.energy_supply.max_energy
	
	ability_cooldown.max_value = player.ability.ability_delay
	ability_character_cooldown.max_value = player.ability_character.ability_delay
	
	ability_cooldown.texture_progress = player.ability.icon
	ability_character_cooldown.texture_progress = player.ability_character.icon

	melee_display.texture = player.weapon_melee.icon
	ranged_display.texture = player.weapon_ranged.icon


func _process(_delta) -> void:
	if not is_instance_valid(player):
		return
	health_bar.value = player.health.current_health
	energy_bar.value = player.energy_supply.current_energy
	
	if not player.ability.duration_timer.is_stopped():
		ability_cooldown.value = 0
	else:
		ability_cooldown.value = ability_cooldown.max_value - player.ability.cooldown_timer.get_time_left()
	
	if not player.ability_character.duration_timer.is_stopped():
		ability_character_cooldown.value = 0
	else:
		ability_character_cooldown.value = ability_character_cooldown.max_value - player.ability_character.cooldown_timer.get_time_left()


func _on_Health_max_changed(new_value : float) -> void:
	health_bar.max_value = new_value


func _on_Energy_max_changed(new_value : float) -> void:
	energy_bar.max_value = new_value


func _on_Ability_delay_changed(new_value : float) -> void:
	ability_cooldown.max_value = new_value


func _on_Ability_character_delay_changed(new_value : float) -> void:
	ability_character_cooldown.max_value = new_value


func _on_Player_ability_changed() -> void:
	ability_cooldown.texture_progress = player.ability.icon
	_on_Ability_delay_changed(player.ability.ability_delay)


func _on_Player_weapon_changed() -> void:
	melee_display.texture = player.weapon_melee.icon
	ranged_display.texture = player.weapon_ranged.icon


func _on_Player_weapon_switched(switched_to : String) -> void:
	if switched_to == "melee":
		pass
	else:
		pass
