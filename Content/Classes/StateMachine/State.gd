extends Node

class_name State

# Late initialization reference to StateMachine
var its_state_machine : StateMachine

# Late initialization reference to Object that have this state
var its_state_object  : Node

func Enter () -> void:
	pass
	
func Exit () -> void:
	pass
	
func Handle_input (_event : InputEvent) -> void:
	pass
	
func Update (_delta : float) -> void:
	pass

func Physics_update (_delta : float) -> void:
	pass
