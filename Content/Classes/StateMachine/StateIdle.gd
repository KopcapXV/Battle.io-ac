extends State

class_name StateIdle

# / Enter state function /
# Use: Put extra conditions and dependencies
# upon entering the state
func Enter ():
	print("idle enter")

# / Exit state function /
# Use: Put extra conditions and dependencies
# upon exiting the state
func Exit ():
	pass

# / Handle player input function /
# Use: Detecting player input while in current state
# to change the state dynamicly (only for not blocking states)
func Handle_input (_event):
	# Handle movement
	if 	(Input.get_vector("left", "right", "up", "down") != Vector2.ZERO):
		its_state_machine.Change_state("statemove")
		
	# Handle attacking
	elif (Input).is_action_just_pressed("attack_1"):

		its_state_machine.Change_state("statedashattack")
	
# / Update state function /
func Update (_delta):
	its_state_object.for_animation_object.play("idle")

# / Physics update function /
# Use: Updation of the physical parameters  of the player
func Physics_update (_delta):
	pass
