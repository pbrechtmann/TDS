extends Weapon
class_name WeaponAttachment

enum TYPE { GENERAL, MELEE, RANGED }

export(TYPE) var type = TYPE.GENERAL

var weapon : Weapon


func init(user : Entity, _dps : float, _new_weapon : bool) -> void:
	self.user = user
