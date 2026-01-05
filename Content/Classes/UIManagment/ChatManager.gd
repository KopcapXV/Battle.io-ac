extends Node

@export var input_field : LineEdit
@export var chat_table 	: TextEdit
var message_history : Array [ChatMessage] = []

func SERVER_Get_chat_message () -> ChatMessage:
	var message : ChatMessage
	# - ! - ! - ! - ! - ! -
	# REQUEST TO SERVER
	# Messages DATA -> id of a session, player nickname,
	# sent message, timestamp
	# - ! - ! - ! - ! - ! -
	return message
	
	
func SERVER_Send_chat_message (message : ChatMessage) -> bool:
	# - ! - ! - ! - ! - ! -
	# SEND TO SERVER
	# Messages DATA -> id of a session, player nickname,
	# sent message, timestamp
	# - ! - ! - ! - ! - ! -
	# if block ->
	return true
	
	
func Send_message () -> void:
	var message = input_field.text.strip_edges()
	var time = "now" # timestamp shit
	if (message.length() > 0):
		var chat_message = ChatMessage.create(
			ThisClient.player_current_session,
			ThisClient.player_nickname,
			message,
			time
		)
		SERVER_Send_chat_message(chat_message)
		Table_add_message(chat_message)
		input_field.release_focus()


func Table_add_message (chat_message : ChatMessage) -> void:
	if (chat_message.session == ThisClient.player_current_session):
		message_history.append(chat_message)
		var formatted_message = "[%s] (%s) : %s" % [chat_message.nickname, chat_message.time, chat_message.message]
		chat_table.text += formatted_message + "\n"
		chat_table.scroll_vertical = chat_table.get_line_count()
	else:
		pass

func on_text_submitted () -> void:
	pass


func _input (event : InputEvent) -> void:
	if (Input.is_action_just_pressed("send")):
		Send_message()
