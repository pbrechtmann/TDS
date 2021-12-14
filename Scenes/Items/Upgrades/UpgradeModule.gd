extends Node
class_name UpgradeModule

enum type {CHARACTER, WEAPON, ARMOR, ABILITY}

var upgrade_type : int

var user : Entity


var modded_stat : String
var modded_val : float


# add upgrade to character
func _init(target : Entity, u_type : int, stat : String, val : float):
	user = target
	upgrade_type = u_type
	modded_stat = stat
	modded_val = val
	#user.add_child(self)
	match upgrade_type:
		type.CHARACTER:
			pass
		type.WEAPON:
			pass
		type.ARMOR:
			pass
		type.ABILITY:
			pass


# remove upgrade from character
func _on_UpgradeModule_tree_exiting():
	match upgrade_type:
		type.CHARACTER:
			pass
		type.WEAPON:
			pass
		type.ARMOR:
			pass
		type.ABILITY:
			pass
