extends Drop
class_name ItemDrop

enum ITEM_TYPE { ABILITY, ARMOR, WEAPON }

export(PackedScene) var scene
export(ITEM_TYPE) var type


func activate(user : Entity) -> void:
	match type:
		ITEM_TYPE.ABILITY:
			user.pickup_ability(scene)
		ITEM_TYPE.ARMOR:
			pass
		ITEM_TYPE.WEAPON:
			user.pickup_weapon(scene)
	
	.activate(user)


func init(scn : PackedScene, type : int, tex : Texture) -> void:
	scene = scn
	self.type = type
	texture = tex
