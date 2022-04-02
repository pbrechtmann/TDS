extends Node
class_name ActionLock

var move_locks : int = 0
var action_locks : int = 0


func add_move_lock() -> void:
	move_locks += 1

func remove_move_lock() -> void:
	move_locks -= 1

func is_move_locked() -> bool:
	return move_locks != 0


func add_action_lock() -> void:
	action_locks += 1

func remove_action_lock() -> void:
	action_locks -= 1

func is_action_locked() -> bool:
	return action_locks != 0
