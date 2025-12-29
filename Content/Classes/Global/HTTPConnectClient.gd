class_name HTTPConnectClient
extends Node

signal SessionAccepted(URL: String, port : int)

const client_version : int = 1

const PREFIX : String = "http://"
const SERVER_URL : String = "127.0.0.1:5000"
const CONNECT_TO_ROOM_ENDPOINT : String = "/connect"
var ROOM_URL : String = "127.0.0.1"
var ROOM_WS_PORT : int = 9080
var ROOM_ACCEPT_PORT : int = 9090

var playerId : int = 333
var globalId : int 
var roomKey : int = 222

var _room_accepter : HTTPRequest = HTTPRequest.new()
var session_accepted : bool = false:
	get: return session_accepted
	set(value):
		if session_accepted != value:
			session_accepted = value
			if session_accepted: SessionAccepted.emit(ROOM_URL, ROOM_WS_PORT)

var _new_room_requester : HTTPRequest = HTTPRequest.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerId = randi_range(10, 40)
	add_child(_room_accepter)
	_room_accepter.request_completed.connect(_accept_session_response)
	
	add_child(_new_room_requester)
	_new_room_requester.request_completed.connect(_get_room_response)
	
	#get_room()
	#await SessionAccepted
	#await get_tree().create_timer(3).timeout
	accept_session()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_room():
	print("<Server> : trying to get connect to room")
	var err : Error
	var body : String = JSON.new().stringify({
		"version": client_version,
		"player_id" : playerId
	})
	_new_room_requester.request(PREFIX + SERVER_URL + CONNECT_TO_ROOM_ENDPOINT, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	
func _get_room_response(result, response_code, headers, body):
	var string_body : String = body.get_string_from_utf8()
	print("<Server> : accept response with code ", response_code, " and body ", string_body)
	if (response_code == 200) and (string_body != null):
		var receive_dict : Dictionary = JSON.parse_string(string_body)
		if receive_dict.has("address"):
			ROOM_URL = receive_dict["address"]
		if receive_dict.has("APORT"):
			ROOM_ACCEPT_PORT = int(receive_dict["APORT"])
		accept_session()
		print("<Server> : received dict is ", receive_dict)

func accept_session():
	print("<Server> : connecting to accepter")
	var err : Error
	var body : String = JSON.new().stringify({
		"playerId": playerId
	})
	print("<Server> : player id is ", playerId)
	#while err != OK:
	err = _room_accepter.request(PREFIX + ROOM_URL + ":" + str(ROOM_ACCEPT_PORT), [], HTTPClient.METHOD_POST, body)
		#await get_tree().create_timer(1).timeout


func _accept_session_response(result, response_code, headers, body):
	var string_body : String = body.get_string_from_utf8()
	if (response_code == 200) and (string_body != "0"):
		var count_right_answers : int = 0 # it helps us for get count right keys in dict
		var receive_dict : Dictionary = JSON.parse_string(string_body)
		
		if receive_dict.has("roomKey"):
			roomKey = int(receive_dict["roomKey"])
			count_right_answers += 1
		if receive_dict.has("globalId"):
			globalId = int(receive_dict["globalId"])
			count_right_answers += 1
		if receive_dict.has("roomPort"):
			ROOM_WS_PORT = int(receive_dict["roomPort"])
			count_right_answers += 1
			
		if count_right_answers == 3:
			session_accepted = true
			
		print("<Server> : received dict is ", receive_dict)
	print("<Server> : accept response with code ", response_code, " and body ", string_body)
