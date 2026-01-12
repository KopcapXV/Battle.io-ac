extends State

class_name StateMove

var _last_direction : Vector2
var direction : Vector2

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
	if its_state_object.is_local_player():
		if (Input).is_action_just_pressed("attack_1"):
			its_state_machine.Change_state("statedashattack")

# / Update state function /
func Update (_delta):
	its_state_object.for_animation_object.play("move")

# / Physics update function /
# Use: Updation of the physical parameters  of the player
func Physics_update (_delta):
	var current_direction : Vector2
	if (its_state_object.is_local_player()):
		current_direction = Input.get_vector("left", "right", "up", "down")
		if current_direction != _last_direction:
			_last_direction = current_direction
			SERVER_Send_direction(current_direction)
		its_state_object.velocity = direction * its_state_object.SPEED
		its_state_object.move_and_slide()
	else:
		current_direction = its_state_object.direction
		
	if (current_direction == Vector2.ZERO):
		#print("<StateMove> : Vector ZERO -> Idle (about)", its_state_object.is_local_player())
		its_state_machine.Change_state("stateidle")
		return
		
	if 	 (current_direction.x > 0):
		its_state_object.for_animation_object.flip_h = false
	elif (current_direction.x < 0):
		its_state_object.for_animation_object.flip_h = true

# / Main client-to-server function for moving players (origin players manager) /
func SERVER_Send_direction(direction : Vector2) -> void:
	var packed_direction : PackedByteArray = [0]
	if direction.x > 0: packed_direction[0] = 128
	if direction.x < 0: packed_direction[0] |= 32
	if direction.y > 0: packed_direction[0] |= 8
	if direction.y < 0: packed_direction[0] |= 2
	print("<StateMove> : packed direction is ", packed_direction)
	WEBSOCKET.send_byte_binary_data(WEBSOCKET.SEND_COMMAND.PLAYER_DIRECTION, packed_direction)
