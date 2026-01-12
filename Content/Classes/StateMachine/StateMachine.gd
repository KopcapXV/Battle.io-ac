extends Node

class_name StateMachine

@export var initial_state 	: State
var current_state 			: State
var states 					: Dictionary = {}
var input_locked 			: bool = false

func _ready () -> void:
	# -- Registration of all child states
	# -- States of the 'Battle.io' classes as nodes
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.its_state_machine = self
			child.its_state_object  = self.get_parent()
	# -- Changing the state		
	if initial_state:
		Change_state(initial_state.name.to_lower())
	Signals.ChatStateChanged.connect(_on_chat_state_changed)
	
func _process (delta : float) -> void:
	if current_state and not input_locked:
		current_state.Update(delta)
	
func _physics_process (delta : float) -> void:
	if current_state:
		current_state.Physics_update(delta)

func _input (event : InputEvent) -> void:
	if input_locked:
		return
	if current_state:
		current_state.Handle_input(event)
	
func Change_state (new_state : String) -> void:
	if current_state:
		current_state.Exit()
	
	current_state = states.get(new_state.to_lower())
	
	if current_state:
		current_state.Enter()
		
func _on_chat_state_changed (is_open : bool) -> void:
	if (is_open):
		Change_state("statelocked")
	else:
		Change_state("stateidle")
	print("<StateMachine> : Chat state changed, input locked: ", is_open)
