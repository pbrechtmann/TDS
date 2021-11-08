extends Entity
class_name NPC

var nav : Navigation2D = null
var target : Entity = null


func init(nav : Navigation2D, target : Entity) -> void:
	self.nav = nav
	self.target = target
