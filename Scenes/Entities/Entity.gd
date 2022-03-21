extends KinematicBody2D
class_name Entity

var effect_damage_bleeding : PackedScene = preload("res://Scenes/Entities/StatusEffects/Variants/DamageEffectBleeding.tscn")
var effect_damage_cold : PackedScene = preload("res://Scenes/Entities/StatusEffects/Variants/DamageEffectCold.tscn")
var effect_damage_fire : PackedScene = preload("res://Scenes/Entities/StatusEffects/Variants/DamageEffectFire.tscn")
var effect_damage_poison : PackedScene = preload("res://Scenes/Entities/StatusEffects/Variants/DamageEffectPoison.tscn")


onready var health : Health = $Health
onready var health_display : HealthDisplay = $HealthDisplay
onready var energy_supply : EnergySupply = $EnergySupply
onready var energy_display : EnergyDisplay = $EnergyDisplay
onready var armor : Armor = $Armor
onready var statmods : StatMods = $StatMods


func _process(delta) -> void:
	health.regenerate(statmods.health_change_per_second, delta)
	energy_supply.regenerate(statmods.energy_change_per_second, delta)
	
	health_display.show_health(health)
	energy_display.show_energy(energy_supply)


func get_damage(modifiers : Dictionary, source : Entity) -> void:
	modifiers = armor.modify(modifiers)
	
	var damage : float = 0
	var crit_chance : float = 0
	var crit_multiplier : float = 1
	
	if modifiers.has("damage"):
		damage = modifiers["damage"]
		
	for key in modifiers:
		match key:
			"crit_chance":
				crit_chance = modifiers[key]
			"crit_multiplier":
				crit_multiplier = modifiers[key]
			"bleeding":
				add_effect(modifiers["bleeding"], effect_damage_bleeding)
			"cold":
				add_effect(modifiers["cold"], effect_damage_cold)
			"fire":
				add_effect(modifiers["fire"], effect_damage_fire)
			"poison":
				add_effect(modifiers["poison"], effect_damage_poison)
	
	if rand_range(0, 1) < crit_chance:
		damage = damage * crit_multiplier
	
	if modifiers.has("lifesteal"):
		source.health.heal(damage * modifiers["lifesteal"])
	
	health.damage(damage)


func add_effect(modifiers : Dictionary, scene : PackedScene) -> void:
	var effect : DamageEffect = scene.instance()
	add_child(effect)
	effect.init(self, modifiers)


func _on_Health_death() -> void:
	queue_free()
