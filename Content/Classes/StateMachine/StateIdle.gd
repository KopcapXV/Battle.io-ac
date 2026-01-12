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
	if (its_state_object.is_local_player()):
		if Input.get_vector("left", "right", "up", "down") != Vector2.ZERO:
			its_state_machine.Change_state("statemove")
			return
		# Handle attacking
		if (Input).is_action_just_pressed("attack_1"):
			its_state_machine.Change_state("statedashattack")
	else:
		if its_state_object.direction != Vector2.ZERO:
			its_state_machine.Change_state("statemove")
	
# / Update state function /
func Update (_delta):
	if its_state_object.is_local_player():
		if Input.get_vector("left", "right", "up", "down") != Vector2.ZERO:
			its_state_machine.Change_state("statemove")
			return
		elif Input.is_action_just_pressed("attack_1"):
			its_state_machine.Change_state("statedashattack")
	else:
		#print("<StateIdle> : anotherplayer dir ", its_state_object.direction)
		if its_state_object.direction != Vector2.ZERO:
			its_state_machine.Change_state("statemove")
			return
	its_state_object.for_animation_object.play("idle")

# / Physics update function /
# Use: Updation of the physical parameters  of the player
func Physics_update (_delta):
	pass
