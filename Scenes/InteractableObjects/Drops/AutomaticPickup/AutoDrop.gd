extends Drop
class_name AutoDrop

enum ATTRIBUTE { ENERGY, HEALTH }
enum TYPE { PERCENTAGE, VALUE }


var target : Entity
var speed : float = 10


var stat_restore : float
var attribute : int
var type : int


func _ready() -> void:
	set_process(false)


func init(attribute : int, type : int, value : float) -> void:
	self.attribute = attribute
	self.type = type
	stat_restore = value


func activate(user : Entity) -> void:
	match attribute:
		ATTRIBUTE.ENERGY:
			match type:
				TYPE.PERCENTAGE:
					user.energy_supply.charge(user.energy_supply.max_energy * stat_restore)
				TYPE.VALUE:
					user.energy_supply.charge(stat_restore)
		ATTRIBUTE.HEALTH:
			match type:
				TYPE.PERCENTAGE:
					user.health.heal(user.health.max_health * stat_restore)
				TYPE.VALUE:
					user.health.heal(stat_restore)
	queue_free()


func start(target : Entity) -> void:
	self.target = target
	set_process(true)


func _process(_delta) -> void:
	if is_instance_valid(target):
		global_position += global_position.direction_to(target.global_position) * speed


func _on_AutoDrop_body_entered(body) -> void:
	if body == target:
		activate(target)
