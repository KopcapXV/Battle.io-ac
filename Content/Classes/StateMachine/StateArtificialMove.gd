extends StateMove

class_name StateArtificialMove

# / Enter state function /
# Use: Put extra conditions and dependencies
# upon entering the state
func Enter ():
	print("move enter")
	
# / Exit state function /
# Use: Put extra conditions and dependencies
# upon exiting the state
func Exit ():
	pass

# / Handle player input function /
# Use: Detecting player input while in current state
# to change the state dynamicly (only for not blocking states)
func Handle_input (_event):
	# Handle attacking
	if (Input).is_action_just_pressed("attack_1"):
		its_state_machine.Change_state("statedashattack")

# / Update state function /
func Update (_delta):
	its_state_object.for_animation_object.play("move")

# / Physics update function /
# Use: Updation of the physical parameters  of the player
func Physics_update (_delta):
	if (direction == Vector2.ZERO):
		its_state_machine.Change_state("stateidle")
		return
		
	its_state_object.velocity = direction * its_state_object.stat_speed
	its_state_object.move_and_slide()
	
	if 	 (direction.x > 0):
		its_state_object.for_animation_object.flip_h = false
	elif (direction.x < 0):
		its_state_object.for_animation_object.flip_h = true
