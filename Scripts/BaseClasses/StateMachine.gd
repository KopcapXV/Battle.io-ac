extends Node

class_name StateMachine

@export var initial_state 	: State
var current_state 			: State
var states 					: Dictionary = {}

func _ready () -> void:
	# Registration of all child states
	# States of the 'Battle.io' classes as nodes
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.its_state_machine = self
			child.its_state_object  = self.get_parent()
			
	if initial_state:
		Change_state(initial_state.name.to_lower())
	
func _process (delta : float) -> void:
	if current_state:
		current_state.Update(delta)
	
func _physics_process (delta : float) -> void:
	if current_state:
		current_state.Physics_update(delta)

func _input (event : InputEvent) -> void:
	if current_state:
		current_state.Handle_input(event)
	
func Change_state (new_state : String) -> void:
	if current_state:
		current_state.Exit()
	
	current_state = states.get(new_state.to_lower())
	
	if current_state:
		current_state.Enter()
