extends State

class_name StateMovingAttack

@export var cooldown_time : float = 7.0

var timer : Timer
var can_do : bool = true
var _last_direction : Vector2

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = cooldown_time
	timer.timeout.connect(_on_cooldown_finished)
	add_child(timer)
	

# / Enter state function /
func Enter():
	print("moving attack enter")
	
	if (not can_do):
		its_state_machine.Change_state("stateidle")
		return
		
	can_do = false
	timer.start()
	
	its_state_object._on_ability_used.emit(cooldown_time)
		
	if not its_state_object.for_animation_object.animation_finished.is_connected(_on_animation_finished):
		its_state_object.for_animation_object.animation_finished.connect(_on_animation_finished)
		
	its_state_object.for_animation_object.play("attack")
	
	
# / Exit state function /
func Exit():
	if its_state_object.for_animation_object.animation_finished.is_connected(_on_animation_finished):
		its_state_object.for_animation_object.animation_finished.disconnect(_on_animation_finished)
		
	
# / Handle player input function /	
func Handle_input(_event):
	pass
	

# / Update state function /
func Update(_delta):
	pass
	
	
# / Physics update function /
func Physics_update(_delta):
	var current_dir : Vector2
	if its_state_object.is_local_player():
		current_dir = Input.get_vector("left", "right", "up", "down")
		
		if current_dir != _last_direction: 
			_last_direction = current_dir
			SERVER_Send_direction(current_dir)
		
		its_state_object.velocity = current_dir * its_state_object.SPEED
		its_state_object.move_and_slide()
	else:
		current_dir = its_state_object.direction 

	if current_dir.x > 0:
		its_state_object.for_animation_object.flip_h = false
	elif current_dir.x < 0:
		its_state_object.for_animation_object.flip_h = true
		
		
func _on_animation_finished():
	its_state_machine.Change_state("stateidle")

func _on_cooldown_finished() -> void:
	can_do = true
	
	
			
# / Main client-to-server function for moving players (origin players manager) /
func SERVER_Send_direction(direction : Vector2) -> void:
	var packed_direction : PackedByteArray = [0]
	if direction.x > 0: packed_direction[0] = 128
	if direction.x < 0: packed_direction[0] |= 32
	if direction.y > 0: packed_direction[0] |= 8
	if direction.y < 0: packed_direction[0] |= 2
	print("<StateMove> : packed direction is ", packed_direction)
	WEBSOCKET.send_byte_binary_data(WEBSOCKET.SEND_COMMAND.PLAYER_DIRECTION, packed_direction)
