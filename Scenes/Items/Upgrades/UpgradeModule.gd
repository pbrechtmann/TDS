extends Node
class_name UpgradeModule


func init(target : Node2D) -> void:
	target.add_child(self)
	self.set_owner(target)
	apply_upgrade(target)


func apply_upgrade(_to : Node2D) -> void:
	pass


# remove upgrade from character
func _on_UpgradeModule_tree_exiting() -> void:
	pass
