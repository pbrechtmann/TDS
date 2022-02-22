extends Node2D
class_name Ability

export(Texture) var icon
export(Texture) var drop_icon

export(float) var ability_cost = 25
export(float) var ability_delay = 2
export(float) var ability_duration = 5

var ready : bool = true
var user : Entity

onready var cooldown_timer : Timer = $Cooldown
onready var duration_timer : Timer = $Duration


func _ready() -> void:
	set_process(false)


func try_activate_ability(user : Entity) -> void:
	self.user = user
	if ready and user.energy_supply.drain(ability_cost):
		activate_ability(user)
		ready = false
		if ability_duration > 0:
			duration_timer.start(ability_duration)
		else:
			_on_Duration_timeout()


func activate_ability(_user : Entity) -> void:
	if ability_duration > 0:
		set_process(true)


func end_ability() -> void:
	pass


func _process(delta) -> void:
	custom_process(delta)


func custom_process(_delta : float) -> void:
	pass


func _on_Duration_timeout() -> void:
	set_process(false)
	end_ability()
	cooldown_timer.start(ability_delay)


func _on_Cooldown_timeout() -> void:
	ready = true
