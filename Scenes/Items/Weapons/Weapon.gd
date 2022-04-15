extends Node2D
class_name Weapon

onready var delay : Timer = $Timer
onready var attachment_container : Node2D = $AttachmentContainer

export(Texture) var icon
export(Texture) var drop_icon

export(float) var attack_delay = 0.5
export(float, 0, 100) var attack_cost = 25

export var modifiers : Dictionary = {}

export var new_weapon : bool = true

var ready : bool = true
var user : Entity

var attachment : Weapon = null # Type: WeaponAttachment


func init(user : Entity, dps : float, new_weapon : bool) -> void:
	self.user = user
	if new_weapon:
		modifiers["damage"] = new_dps(dps)
		print_debug(modifiers["damage"])
	self.new_weapon = false
	find_attachment()


func try_primary_attack(energy_supply, attack_mods : Dictionary) -> void:
	if ready and energy_supply.drain(attack_cost):
		primary_attack(attack_mods)
		
		ready = false
		delay.start(attack_delay)


func primary_attack(_attack_mods : Dictionary) -> void:
	pass


func try_secondary_attack(energy_supply, attack_mods : Dictionary) -> void:
	if attachment:
		if attachment.ready and energy_supply.drain(attachment.attack_cost):
			attachment.primary_attack(attack_mods)
			
			attachment.ready = false
			attachment.delay.start(attachment.attack_delay)


func attach(attachment_scene : PackedScene) -> void:
	attachment = attachment_scene.instance()
	attachment_container.add_child(attachment)
	attachment.set_owner(self)
	attachment.init(user, true, get_dps())
	attachment.weapon = self


func find_attachment() -> void:
	if attachment_container.get_child_count() == 1:
		attachment = attachment_container.get_child(0)
		attachment.init(user, false, 0)
		attachment.weapon = self


func get_dps() -> float:
	var shots_per_second = 1.0 / attack_delay
	return modifiers["damage"] * shots_per_second


func new_dps(base : float) -> float:
	var shots_per_second = 1.0 / attack_delay
	var base_dmg = base / shots_per_second
	return base_dmg + rand_range(-base_dmg * 0.3, base_dmg * 0.1)


func create_final_mods(attack_mods : Dictionary) -> Dictionary:
	var final_mods = modifiers.duplicate(true)
	if final_mods.has("damage"):
		final_mods["damage"] *= attack_mods["damage"]
	if final_mods.has("lifesteal"):
		final_mods["lifesteal"] += attack_mods["lifesteal"]
	elif attack_mods["lifesteal"] > 0:
		final_mods["lifesteal"] = attack_mods["lifesteal"]
	
	return final_mods


func _on_Timer_timeout() -> void:
	ready = true
