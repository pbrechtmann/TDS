extends KinematicBody2D
class_name Entity

onready var health : Health = $Health
onready var health_display : HealthDisplay = $HealthDisplay
onready var energy_supply : EnergySupply = $EnergySupply
onready var energy_display : EnergyDisplay = $EnergyDisplay
onready var armor : Armor = $BasicArmor


func _process(_delta):
	health_display.show_health(health)
	energy_display.show_energy(energy_supply)


func get_damage(modifiers : Dictionary):
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
	
	if rand_range(0, 1) < crit_chance:
		damage = damage * crit_multiplier
	
	damage = armor.modify_damage(damage)
	
	health.damage(damage)


func _on_Health_death():
	queue_free()
