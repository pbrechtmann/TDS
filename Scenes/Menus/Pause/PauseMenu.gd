extends CanvasLayer
class_name PauseMenu


onready var margin : MarginContainer = $Control/MarginContainer


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
	
	var window : Vector2 = OS.get_window_size()
	
	margin.margin_top = window.y / 3.6
	margin.margin_bottom = -margin.margin_top
	margin.margin_left = window.x / 2.4
	margin.margin_right = -margin.margin_left


func _on_ButtonContinue_button_down():
	get_tree().paused = false
	queue_free()


func _on_ButtonSettings_button_down():
	# Settings Menu needs pause_mode = Node.PAUSE_MODE_PROCESS
	pass # Replace with function body.


func _on_ButtonMenu_button_down():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Menus/Main/MainMenu.tscn")


func _on_ButtonQuit_button_down():
	get_tree().quit()
