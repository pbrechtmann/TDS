extends Node2D

var pause_menu = preload("res://Scenes/Menus/Pause/PauseMenu.tscn")

onready var generator : Generator = $Generator

onready var player : Player = $Player
onready var nav : Navigation2D = $Navigation2D
onready var drop_spawner : DropSpawner = $DropSpawner

onready var ui : UI = $UI


func _ready() -> void:
	if player.connect("game_over", self, "_on_Player_game_over") != OK:
		printerr("Connecting game_over from Player to Level failed.")
	if player.connect("pause", self, "_on_Player_pause") != OK:
		printerr("Connecting pause from Player to Level failed.")
	
	player.init(drop_spawner)
	
	if generator.connect("done", self, "_on_Generator_done") != OK:
		printerr("Failed connecting signal \"done\" from Generator to World")
	
	generate()
	
	ui.init(player)


func generate() -> void:
	player.action_lock.add_action_lock()
	player.action_lock.add_move_lock()
	player.collision_layer = 0
	yield(get_tree(), "idle_frame")
	drop_spawner.clear()
	generator.generate_level(player, nav, drop_spawner)


func _on_Player_game_over() -> void:
	get_tree().call_group("Entity", "queue_free")
	if get_tree().reload_current_scene() != OK:
		printerr("Reloading Game-scene failed")


func _on_Player_pause() -> void:
	player.set_active(false)
	var p_menu = pause_menu.instance()
	add_child(p_menu)
	p_menu.init(self)


func _on_Generator_done() -> void:
	yield(get_tree(), "idle_frame")
	player.collision_layer = 2 + 4
	player.set_active(true)
	player.action_lock.remove_action_lock()
	player.action_lock.remove_move_lock()
	if generator.exit.connect("level_done", self, "_on_Exit_level_done") != OK:
		printerr("Failed connecting signal \"done\" from Generator to World")


func _on_Exit_level_done() -> void:
	player.set_active(false)
	generate()
