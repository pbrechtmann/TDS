extends Node2D

onready var nav = $Navigation2D
onready var player = $Player


func _ready():
	for node in get_tree().get_nodes_in_group("Spawners"):
		node.init(nav, player)
