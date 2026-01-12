extends State

class_name StateLocked

# / Enter state function /
# Use: Put extra conditions and dependencies
# upon entering the state
func Enter () -> void:
	print("chat locked enter")
	
	var direction = Vector2.ZERO
	var packed_direction : PackedByteArray = [0]
	if direction.x > 0: packed_direction[0] = 128
	if direction.x < 0: packed_direction[0] |= 32
	if direction.y > 0: packed_direction[0] |= 8
	if direction.y < 0: packed_direction[0] |= 2
	print("<StateMove> : packed direction is ", packed_direction)
	WEBSOCKET.send_byte_binary_data(WEBSOCKET.SEND_COMMAND.PLAYER_DIRECTION, packed_direction)
	
	its_state_object.velocity = Vector2.ZERO
	its_state_object.modulate = Color(1, 1, 1, 0.7)
	if "direction" in its_state_object:
		its_state_object.direction = Vector2.ZERO
	if "_last_direction" in its_state_object:
		its_state_object._last_direction = Vector2.ZERO
	
# / Exit state function /
# Use: Put extra conditions and dependencies
# upon exiting the state
func Exit () -> void:
	#its_state_object.modulate = Color.WHITE
	its_state_object.modulate = Color(1, 1, 1, 1)
	pass
	
	
# / Handle player input function /
# Use: Detecting player input while in current state
# to change the state dynamicly (only for not blocking states)
func Handle_input (event : InputEvent) -> void:
	if event.is_action_pressed("send"):
		its_state_machine.Change_state("stateidle")
	pass
	
	
# / Update state function /
func Update (_delta : float) -> void:
	its_state_object.for_animation_object.play("idle")
	
	
# / Physics update function /
# Use: Updation of the physical parameters  of the player
func Physics_update (_delta : float) -> void:
	its_state_object.velocity = Vector2.ZERO
