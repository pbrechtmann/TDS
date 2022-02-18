extends KinematicBody2D
class_name Entity

var effect_damage_fire : PackedScene = preload("res://Scenes/Entities/StatusEffects/Variants/DamageEffectFire.tscn")



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
			"fire":
				var fire_effect = effect_damage_fire.instance()
				add_child(fire_effect)
				fire_effect.init(self, modifiers["fire"])
	
	if rand_range(0, 1) < crit_chance:
		damage = damage * crit_multiplier
	
	if modifiers.has("lifesteal"):
		source.health.heal(damage * modifiers["lifesteal"])
	
	health.damage(damage)


func _on_Health_death() -> void:
	queue_free()
