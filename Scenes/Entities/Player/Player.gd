extends Entity
class_name Player

export(float) var speed = 1000
export(float) var dash_force = 4

onready var ranged_container : Node2D = $Weapons/Ranged
onready var melee_container : Node2D = $Weapons/Melee

onready var weapon_ranged : Weapon = ranged_container.get_child(0)
onready var weapon_melee : Weapon = melee_container.get_child(0)

onready var ability : Ability = $AbilityHeal
onready var interaction_area : Area2D = $InteractionArea

var weapon : Weapon

var drop_spawner : DropSpawner

var current_interactable : InteractableObject = null
var overlapping_interactables : Array = []

signal weapon_changed
signal weapon_switched
signal game_over
signal pause


func _ready() -> void:
	weapon = weapon_ranged
	weapon_melee.init(self)


func init(drop_spawner : DropSpawner):
	self.drop_spawner = drop_spawner


func move() -> void:
	var delta_vec = Vector2.ZERO
	delta_vec.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	delta_vec.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	delta_vec = delta_vec.normalized()
	var dash : float = dash_force if Input.is_action_just_pressed("dash") else 1.0
	move_and_slide(delta_vec * speed * dash)


func _physics_process(_delta) -> void:
	move()
	look_at(get_global_mouse_position())


func _process(_delta) -> void:
	if Input.is_action_pressed("attack_primary"):
		weapon.try_primary_attack(energy_supply)


func _unhandled_input(event) -> void:
	if event.is_action_pressed("ability"):
		ability.try_activate_ability(self)
	if not event.is_echo() and event.is_action_pressed("interact") and current_interactable:
		if is_instance_valid(current_interactable):
			current_interactable.activate(self)
	
	if event.is_action_pressed("weapon_hotkey_1"):
		switch_to_ranged()
	
	if event.is_action_pressed("weapon_hotkey_2"):
		switch_to_melee()
	
	if event.is_action_pressed("pause"):
		emit_signal("pause")


func switch_to_ranged() -> void:
	weapon = weapon_ranged
	emit_signal("weapon_switched", "ranged")


func switch_to_melee() -> void:
	weapon = weapon_melee
	emit_signal("weapon_switched", "melee")


func switch_weapons() -> void:
	if weapon == weapon_ranged:
		weapon = weapon_melee
	else:
		weapon = weapon_ranged


func pickup_weapon(weapon_scene : PackedScene) -> void:
	var new_weapon = weapon_scene.instance()
	if new_weapon is WeaponMelee:
		var packed : PackedScene = PackedScene.new()
		packed.pack(weapon_melee)
		drop_spawner.spawn_set_drop(packed, ItemDrop.ITEM_TYPE.WEAPON, melee_container.global_position)
		
		var old_weapon : WeaponMelee = weapon_melee
		weapon_melee = new_weapon
		melee_container.add_child(weapon_melee)
		weapon_melee.init(self)
		
		old_weapon.queue_free()
		
		switch_to_melee()
	
	elif new_weapon is WeaponRanged:
		var packed : PackedScene = PackedScene.new()
		packed.pack(weapon_ranged)
		drop_spawner.spawn_set_drop(packed, ItemDrop.ITEM_TYPE.WEAPON, ranged_container.global_position)
		
		var old_weapon : WeaponRanged = weapon_ranged
		weapon_ranged = new_weapon
		ranged_container.add_child(weapon_ranged)
		
		old_weapon.queue_free()
		
		switch_to_ranged()
	
	emit_signal("weapon_changed")


func _on_Health_death() -> void:
	emit_signal("game_over")
	._on_Health_death()


func _on_InteractionArea_area_entered(area) -> void:
	if area is InteractableObject:
		overlapping_interactables.append(area)
		current_interactable = area


func _on_InteractionArea_area_exited(area) -> void:
	if area == current_interactable:
		current_interactable = null
		overlapping_interactables.erase(area)
		yield(get_tree(), "idle_frame")
		current_interactable = null if overlapping_interactables.empty() else overlapping_interactables[0]
