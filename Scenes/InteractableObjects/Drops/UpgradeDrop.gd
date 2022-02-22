extends Drop
class_name UpgradeDrop

enum UPGRADE_TYPE { ABILITY, ARMOR, CHARACTER, WEAPON, WEAPON_MELEE, WEAPON_RANGED }

export(PackedScene) var scene
export(UPGRADE_TYPE) var type


func activate(user : Entity) -> void:
	var upgrade : UpgradeModule = scene.instance()
	match type:
		UPGRADE_TYPE.ABILITY:
			if user.ability:
				upgrade.apply_upgrade(user.ability)
			else:
				return
		UPGRADE_TYPE.ARMOR:
			upgrade.apply_upgrade(user.armor)
		UPGRADE_TYPE.CHARACTER:
			upgrade.apply_upgrade(user)
		UPGRADE_TYPE.WEAPON:
			upgrade.apply_upgrade(user.weapon)
		UPGRADE_TYPE.WEAPON_MELEE:
			upgrade.apply_upgrade(user.weapon_melee)
		UPGRADE_TYPE.WEAPON_RANGED:
			upgrade.apply_upgrade(user.weapon_ranged)
	
	.activate(user)


func init(scn : PackedScene, type : int) -> void:
	scene = scn
	self.type = type
