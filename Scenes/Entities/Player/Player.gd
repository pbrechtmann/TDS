extends Entity
class_name Player

export(float) var speed = 1000
export(float) var dash_force = 4

onready var weapon : Weapon = $WeaponRanged
onready var ability : Ability = $AbilityHeal
onready var interaction_area : Area2D = $InteractionArea

var current_interactable : InteractableObject = null
var overlapping_interactables : Array = []

signal game_over
signal pause


func _ready():
	if weapon is WeaponMelee:
		weapon.init(self)

func move():
	var delta_vec = Vector2.ZERO
	delta_vec.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	delta_vec.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	delta_vec = delta_vec.normalized()
	var dash : float = dash_force if Input.is_action_just_pressed("dash") else 1.0
	move_and_slide(delta_vec * speed * dash)


func _physics_process(_delta):
	move()
	look_at(get_global_mouse_position())


func _process(_delta):
	if Input.is_action_pressed("attack_primary"):
		weapon.try_primary_attack(energy_supply)


func _unhandled_input(event):
	if event.is_action_pressed("ability"):
		ability.try_activate_ability(self)
	if not event.is_echo() and event.is_action_pressed("interact") and current_interactable:
		if is_instance_valid(current_interactable):
			current_interactable.activate(self)
	
	if event.is_action_pressed("pause"):
		emit_signal("pause")


func _on_Health_death() -> void:
	emit_signal("game_over")
	._on_Health_death()


func _on_InteractionArea_area_entered(area):
	if area is InteractableObject:
		overlapping_interactables.append(area)
		current_interactable = area


func _on_InteractionArea_area_exited(area):
	if area == current_interactable:
		current_interactable = null
		overlapping_interactables.erase(area)
		yield(get_tree(), "idle_frame")
		current_interactable = null if overlapping_interactables.empty() else overlapping_interactables[0]
