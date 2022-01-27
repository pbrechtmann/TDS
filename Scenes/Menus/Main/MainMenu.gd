extends Control
class_name MainMenu

onready var margin : MarginContainer = $MarginContainer


func _ready() -> void:
	# adjusting main menu to 16:9 screens
	var window : Vector2 = OS.get_window_size()
	
	margin.margin_top = window.y / 1.44
	margin.margin_bottom = window.y / -21.6
	margin.margin_left = window.x / 38.4
	margin.margin_right = window.x / -1.28


func _on_ButtonStart_button_down() -> void:
	if get_tree().change_scene("res://Scenes/World.tscn") != OK:
		printerr("Loading Game-scene failed")


func _on_ButtonSettings_button_down() -> void:
	pass # Replace with function body.


func _on_ButtonQuit_button_down() -> void:
	get_tree().quit()
