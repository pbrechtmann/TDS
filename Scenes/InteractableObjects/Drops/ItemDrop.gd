extends Drop
class_name ItemDrop

enum ITEM_TYPE { WEAPON, ARMOR }

export(PackedScene) var scene
export(ITEM_TYPE) var type


func activate(user : Entity) -> void:
	match type:
		ITEM_TYPE.WEAPON:
			user.pickup_weapon(scene)
		ITEM_TYPE.ARMOR:
			pass
	
	.activate(user)


func init(scn : PackedScene, type : int) -> void:
	scene = scn
	self.type = type
