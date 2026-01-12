extends State

class_name StateDashAttack

@export var dash_distance : float = 95.0

@export var cooldown_time : float = 3.0

var timer : Timer

var can_do : bool = true

func _ready () -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = cooldown_time
	timer.timeout.connect(_on_cooldown_finished)
	add_child(timer)
	

# / Enter state function /
# Use: Put extra conditions and dependencies
# upon entering the state
func Enter ():
	print("attack enter")
	
	var direction = Vector2.ZERO
	var packed_direction : PackedByteArray = [0]
	if direction.x > 0: packed_direction[0] = 128
	if direction.x < 0: packed_direction[0] |= 32
	if direction.y > 0: packed_direction[0] |= 8
	if direction.y < 0: packed_direction[0] |= 2
	print("<StateMove> : packed direction is ", packed_direction)
	WEBSOCKET.send_byte_binary_data(WEBSOCKET.SEND_COMMAND.PLAYER_DIRECTION, packed_direction)
	
	if (not can_do):
		its_state_machine.Change_state("stateidle")
		return
		
	can_do = false
	timer.start()
	
	its_state_object._on_ability_used.emit(cooldown_time)
	
	if not its_state_object.for_animation_object.animation_finished.is_connected(_on_animation_finished):
		its_state_object.for_animation_object.animation_finished.connect(_on_animation_finished)
	
# / Exit state function /
# Use: Put extra conditions and dependencies
# upon exiting the state
func Exit ():
	if its_state_object.for_animation_object.animation_finished.is_connected(_on_animation_finished):
		its_state_object.for_animation_object.animation_finished.disconnect(_on_animation_finished)
	
# / Handle player input function /
# Use: Detecting player input while in current state
# to change the state dynamicly (only for not blocking states)
func Handle_input (_event):
	pass
	
# / Update state function /
func Update (_delta):
	its_state_object.for_animation_object.play("attack")

# / Physics update function /
# Use: Updation of the physical parameters  of the player
func Physics_update (_delta):
	pass

# Additional function for handling dash physically
func Apply_dash_movement():
	var direction = Vector2.RIGHT
	if its_state_object.for_animation_object.flip_h:
		direction = Vector2.LEFT

	var movement_vector = direction * dash_distance
	
	# Using move_and_collide instead of stupid changing position
	its_state_object.move_and_collide(movement_vector)
	
# Signal of animatied sprite for animation end
func _on_animation_finished():
	Apply_dash_movement()
	its_state_machine.Change_state("stateidle")

func _on_cooldown_finished () -> void:
	can_do = true
