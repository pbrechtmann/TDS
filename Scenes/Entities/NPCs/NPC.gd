extends Entity
class_name NPC

var nav : Navigation2D = null
var target : Entity = null
var drop_spawner : DropSpawner = null


func init(nav : Navigation2D, target : Entity, drop_spawner) -> void:
	self.nav = nav
	self.target = target
	self.drop_spawner = drop_spawner
