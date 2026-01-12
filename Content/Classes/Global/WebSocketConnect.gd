class_name WebSocketMeneger
extends Node

signal ConnectToServerSuccessed
signal ConnectToServerFailed

signal ConnectionClosed(code : int)


# 256 cpmmand maximum
enum SEND_COMMAND{
	NONE,
	VECTOR2,
	PLAYER_DIRECTION,
	PLAYER_SHOOT,
	MESSAGE
}

# 256 cpmmand maximum
enum RECEIVE_COMMAND{
	NONE,
	ENTITY_POSITION,
	
	PLAYER_POSITION,
	PLAYER_DIRECTION,
	PLAYER_DAMAGED,
	PLAYER_DEAD,
	
	BULLET_POSITION,
	BULLET_DIRECTION,
	
	MESSAGE,
	
	GAME_STATE = 255
}

const FLOAT_ACCURACY = 1000
const WS_PREFIX = "ws://"

var mutex_socket : Mutex = Mutex.new()
var socket : WebSocketPeer

var player_id_in_byte_array : PackedByteArray = [0, 0, 0, 0]
var player_id : int = 0:
	get: return player_id
	set(value):
		if player_id != value:
			player_id = value
			player_id_in_byte_array[0] = ((player_id >> 24) & 0xFF)
			player_id_in_byte_array[1] = ((player_id >> 16) & 0xFF)
			player_id_in_byte_array[2] = ((player_id >> 8) & 0xFF)
			player_id_in_byte_array[3] = (player_id & 0xFF)
			
var room_key_in_byte_array : PackedByteArray = [0, 0, 0, 0]
var room_key : int = 0:
	get: return room_key
	set(value):
		if room_key != value:
			room_key = value
			room_key_in_byte_array[0] = ((room_key >> 24) & 0xFF)
			room_key_in_byte_array[1] = ((room_key >> 16) & 0xFF)
			room_key_in_byte_array[2] = ((room_key >> 8) & 0xFF)
			room_key_in_byte_array[3] = (room_key & 0xFF)
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CLIENT.SessionAccepted.connect(_start)

func _start(URL : String, port : int):
	player_id = CLIENT.playerId
	room_key = CLIENT.roomKey
	socket = await _connect_url(WS_PREFIX + URL + ":" + str(port))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	mutex_socket.lock()
	if (socket != null):
		socket.poll()
		while socket.get_available_packet_count() > 0:
			match socket.get_ready_state():
				WebSocketPeer.STATE_OPEN:
					#print("<Websocket> : packet is ",socket.get_packet())
					analyze_receive_data(socket.get_packet())
				WebSocketPeer.STATE_CLOSING:
					print("<Websocket> : connection closing...")
				WebSocketPeer.STATE_CLOSED:
					print("<Websocket> : connection closed with code ", socket.get_close_code(), " and reason ", socket.get_close_reason())
				_:
					pass
	mutex_socket.unlock()


func send_binary_data(command : SEND_COMMAND, data : PackedInt32Array):
	mutex_socket.lock()
	if socket != null and CLIENT.session_accepted:
		socket.poll()
		match socket.get_ready_state():
			WebSocketPeer.STATE_OPEN:
				var bytes : PackedByteArray = []
				# pack headers
				bytes.append_array(player_id_in_byte_array)
				#print("<Websocket> : playerID in bytes is ", bytes)
				bytes.append_array(room_key_in_byte_array)
				#print("<Websocket> : playerID ands roomKey in bytes is ", bytes)
				bytes.push_back(command & 0xFF)
				
				# pack int data
				
				for num in data:
					bytes.append_array(_int32_to_bytes(num))
				
				print("<Websocket> : raw byte is ", bytes, " and size send data is ", bytes.size())
				socket.send(bytes)
				
			WebSocketPeer.STATE_CLOSING:
				print("<Websocket> : connection closing...")
			WebSocketPeer.STATE_CLOSED:
				print("<Websocket> : connection closed with code ", socket.get_close_code())
				ConnectionClosed.emit(socket.get_close_code())
			_:
				pass
	mutex_socket.unlock()
	
func send_byte_binary_data(command : SEND_COMMAND, data : PackedByteArray):
	mutex_socket.lock()
	if socket != null and CLIENT.session_accepted:
		socket.poll()
		match socket.get_ready_state():
			WebSocketPeer.STATE_OPEN:
				
				var bytes : PackedByteArray = []
				# pack headers
				bytes.append_array(player_id_in_byte_array)
				#print("<Websocket> : playerID in bytes is ", bytes)
				bytes.append_array(room_key_in_byte_array)
				#print("<Websocket> : playerID ands roomKey in bytes is ", bytes)
				bytes.push_back(command & 0xFF)
				
				#pack data
				bytes.append_array(data)
				
				#print("<Websocket> : raw byte is ", bytes, " and size send data is ", bytes.size())
				socket.send(bytes)
				
			WebSocketPeer.STATE_CLOSING:
				print("<Websocket> : connection closing...")
			WebSocketPeer.STATE_CLOSED:
				print("<Websocket> : connection closed with code ", socket.get_close_code())
				ConnectionClosed.emit(socket.get_close_code())
			_:
				pass
	mutex_socket.unlock()
	
func send_string(command : SEND_COMMAND, data : String):
	match command:
		SEND_COMMAND.MESSAGE:
			
			var byte_data : PackedByteArray = data.to_utf16_buffer()
			send_byte_binary_data(command, byte_data)

func _connect_url(url : String) -> WebSocketPeer:
	var current_socket : WebSocketPeer = WebSocketPeer.new()
	
	if current_socket.connect_to_url(url) == OK:
		print("<Websocket> : connecting to %s..." % url )
		
		# await normal connecting
		while current_socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
			await get_tree().create_timer(0.5).timeout
			current_socket.poll()
			print("<Websocket> : connecting with state ", current_socket.get_ready_state())
		print("<Websocket> : connected on address ", current_socket.get_connected_host(), " and port ", current_socket.get_connected_port())
		
		# packed and send auth bytes
		#pack
		var bytes : PackedByteArray = []
		bytes.append_array(player_id_in_byte_array)
		bytes.append_array(room_key_in_byte_array)
		bytes.push_back(0)
		
		#send..
		current_socket.send(bytes)
		ConnectToServerSuccessed.emit()
		current_socket.set_no_delay(true) # no delay for fast data share
		return current_socket
	else:
		printerr("<Websocket> : can't connect")
		ConnectToServerFailed.emit()
		return null

func analyze_receive_data(packet : PackedByteArray):
	if packet.size() < 5 : 
		#print("<Websocket> : received packet too short: ", packet)
		return
	#print("<Websocket> : received packet - ", packet)
	var command : int = packet[0]
	var entity_id : int = _get_int32_from_packet(packet, 1, 4)
	match command:
		# Get player position
		RECEIVE_COMMAND.PLAYER_POSITION:
			var position : Vector2 = _get_vector2_from_packet(packet, 5)
			GAME_DATA.mutexPlayersPosition.lock()
			GAME_DATA.players_position[entity_id] = position
			GAME_DATA.mutexPlayersPosition.unlock()
		# Get direction of player in ONE vector
		RECEIVE_COMMAND.PLAYER_DIRECTION:
			GAME_DATA.mutexPlayersDirection.lock()
			GAME_DATA.players_direction[entity_id] = _get_direction_from_byte(packet, 5)
			#print("<Websocket> : get direction: ", packet)
			GAME_DATA.mutexPlayersDirection.unlock()
		
		# Get damage of any player
		RECEIVE_COMMAND.PLAYER_DAMAGED:
			Signals.PlayerDamaged.emit(entity_id, _get_int32_from_packet(packet, 5, 8), _get_int32_from_packet(packet, 9, 12))
		
		# Get kill state of any player
		RECEIVE_COMMAND.PLAYER_DEAD:
			Signals.PlayerKilled.emit(entity_id)
		
		# Game state
		RECEIVE_COMMAND.GAME_STATE:
			Signals.GameStateChanged.emit(_get_int32_from_packet(packet, 5, 8))
			#print("<Websocket> : getted state: ", _get_int32_from_packet(packet, 5, 8) )
		
		# All bullets positions
		RECEIVE_COMMAND.BULLET_POSITION:
			var position : Vector2 = _get_vector2_from_packet(packet, 5)
			GAME_DATA.mutexBulletsPosition.lock()
			GAME_DATA.bullets_position[entity_id] = position
			GAME_DATA.mutexBulletsPosition.unlock()
			print("<Websocket> : getted command - ", command, " and entity_id - ", entity_id, " and data is ", position)
		RECEIVE_COMMAND.MESSAGE:
			#print("<Websocket> : getted new message!")
			Signals.ChatMessageWasGet.emit(entity_id, _get_string_utf16_from_packet(packet, 5, packet.size()))
			#print("<Websocket ", CLIENT.globalId, " > : reseived message from : ", entity_id, " and text - ", _get_string_utf16_from_packet(packet, 5, packet.size()))
		_:
			print("<Websocket> : getted unknown command: ", command)

## !!!BE CAREFUL!!!
# from - first byte, to - size packet array
func _get_string_utf16_from_packet(packet : PackedByteArray, from : int, to : int) -> String:
	var raw_string : PackedByteArray;
	for i in range(from, to):
		raw_string.append(packet[i])
	return raw_string.get_string_from_utf16()
	
## !!!BE CAREFUL!!!
# from - first byte of int32, to - last byte of int32
func _get_int32_from_packet(packet : PackedByteArray, from : int, to : int) -> int:
	var ret : int = 0
	for i : int in range(from, to + 1):
		ret <<= 8
		ret |= packet[i]
	if packet[from] >> 7: 
		ret -= 0x100000000
	return ret
	
func _get_vector2_from_packet(packet : PackedByteArray, from : int) -> Vector2:
	if (packet.size()) < (from + 4 + 4 + 4 + 3):
		print("<Websocket> : error to get vector2 from packet. It so small")
		return Vector2.ZERO
	var ret : Vector2
	ret.x = _get_int32_from_packet(packet, from, from + 3)
	ret.x += (float(_get_int32_from_packet(packet, from + 4, from + 4 + 3)) / FLOAT_ACCURACY)
	ret.y = _get_int32_from_packet(packet, from + 4 + 4, from + 4 + 4 + 3)
	ret.y += (float(_get_int32_from_packet(packet, from + 4 + 4 + 4, from + 4 + 4 + 4 + 3)) / FLOAT_ACCURACY)
	return ret
	
func _get_direction_from_byte(packet : PackedByteArray, from : int) -> Vector2:
	if (packet.size()) < (from + 1): 
		return Vector2.ZERO
	var ret : Vector2
	#print("<Websocket> : getted packet[from] ", packet[from])
	if (packet[from] & 128) > 1: ret.x += 1
	if (packet[from] & 32) > 1: ret.x -= 1
	if (packet[from] & 8) > 1: ret.y += 1
	if (packet[from] & 2) > 1: ret.y -= 1
	
	return ret.normalized()
	
func _int32_to_bytes(value : int) -> PackedByteArray:
	var ret : PackedByteArray
	
	ret.push_back((value >> 24) & 0xFF)
	ret.push_back((value >> 16) & 0xFF)
	ret.push_back((value >> 8) & 0xFF)
	ret.push_back(value & 0xFF)

	return ret


func _vector2_to_bytes(value : Vector2, accuracy : int) -> PackedByteArray:
	var ret : PackedByteArray
	ret.append_array(_int32_to_bytes(int(value.x)))
	ret.append_array(_int32_to_bytes(int(value.x * accuracy ) - int(value.x) * accuracy))
	ret.append_array(_int32_to_bytes(int(value.y)))
	ret.append_array(_int32_to_bytes(int(value.y * accuracy ) - int(value.y) * accuracy))
	
	return ret
