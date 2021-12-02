extends Control
class_name MainMenu


func _on_ButtonStart_button_down():
	get_tree().change_scene("res://Scenes/World.tscn")


func _on_ButtonSettings_button_down():
	pass # Replace with function body.


func _on_ButtonQuit_button_down():
	get_tree().quit()
