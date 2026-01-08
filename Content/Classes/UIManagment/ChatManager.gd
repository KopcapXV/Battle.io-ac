extends Node

# -- Chats input text box field
@export var chat_field : LineEdit
# -- Chats table frame
@export var chat_table 	: TextEdit
# -- Chats history (!unused fornow!)
var message_history : Array [ChatMessage] = []

# -- Animation player node for the chat
@export var chat_animator : AnimationPlayer
# -- Animation player node for the chat toggler
@export var toggler_animator : AnimationPlayer
# -- Button node for toggling chat visibility
@export var chat_toggler : TextureButton
# -- Chats state enum
enum ChatState { COLLAPSED, COLLAPSING, EXPANDED, EXPANDING }
# -- Variable for the chats currents state
var current_state : ChatState

# ---- # ---- # UI & ANIMATION CONTROL SIDE # ---- # ---- #

func _ready () -> void:
	Setup_chat_state()
	#chat_toggler.scale = Vector2.ONE

# --- Function to set up the initial state of chat UI & anims
func Setup_chat_state () -> void:
	CHAT_Enter_collapsed_state()
	chat_toggler.pressed.connect(_on_chat_toggler_pressed)
	chat_toggler.mouse_entered.connect(_on_chat_toggler_mouse_entered)
	chat_toggler.mouse_exited.connect(_on_chat_toggler_mouse_exited)
	chat_animator.animation_finished.connect(_on_animation_finished)
	
# --- Chats function for hidden state
func CHAT_Enter_collapsed_state () -> void:
	current_state = ChatState.COLLAPSED
	chat_field.hide()
	chat_table.hide()
	
	
# --- Chats function for hiding state
func CHAT_Enter_collapsing_state () -> void:
	if current_state != ChatState.EXPANDED:
		return
	current_state = ChatState.COLLAPSING
	chat_animator.play("chat_collapse")


# --- Chats function for showing state
func CHAT_Enter_expanding_state () -> void:
	if current_state != ChatState.COLLAPSED:
		return
	current_state = ChatState.EXPANDING
	chat_field.show()
	chat_table.show()
	chat_animator.play("chat_expand")
		
		
# --- Chats function for shown state
func CHAT_Enter_expanded_state () -> void:
	current_state = ChatState.EXPANDED
		
		
# --- Signal function for toggling chat
func _on_chat_toggler_pressed():
	if current_state == ChatState.COLLAPSING or current_state == ChatState.EXPANDING:
		return
	match current_state:
		ChatState.COLLAPSED:
			CHAT_Enter_expanding_state()
		ChatState.EXPANDED:
			CHAT_Enter_collapsing_state()
		_:
			pass

		
func _on_animation_finished (animation_name : String) -> void:
	match animation_name: 
		"chat_expand":
			CHAT_Enter_expanded_state()
		"chat_collapse":
			CHAT_Enter_collapsed_state()
		_:
			pass
		
func _on_chat_toggler_mouse_entered():
	toggler_animator.play("button_hover")

func _on_chat_toggler_mouse_exited():
	toggler_animator.play("button_unhover")


# ---- # ---- # MESSAGE CONTROL SIDE # ---- # ---- #

# --- PH function for getting message form the server
func SERVER_Get_chat_message () -> ChatMessage:
	var message : ChatMessage
	# - ! - ! - ! - ! - ! -
	# REQUEST TO SERVER
	# Messages DATA -> id of a session, player nickname,
	# sent message, timestamp
	# - ! - ! - ! - ! - ! -
	return message
	

# --- PH function for sending message to the server
func SERVER_Send_chat_message (message : ChatMessage) -> bool:
	# - ! - ! - ! - ! - ! -
	# SEND TO SERVER
	# Messages DATA -> id of a session, player nickname,
	# sent message, timestamp
	# - ! - ! - ! - ! - ! -
	# if block ->
	return true
	

# --- Function for submitting and sending message to the chat
func Send_message () -> void:
	var message = chat_field.text.strip_edges()
	var time = Time.get_time_string_from_system() # Overwrite by the server
	if (message.length() > 0):
		var chat_message = ChatMessage.create(
			ThisClient.player_current_session,
			ThisClient.player_nickname,
			message,
			time
		)
		SERVER_Send_chat_message(chat_message)
		Table_add_message(chat_message)
		chat_field.text = ""

# --- Function for applying message to the chat table
func Table_add_message (chat_message : ChatMessage) -> void:
	if (chat_message.session == ThisClient.player_current_session):
		message_history.append(chat_message)
		var formatted_message = "[%s] (%s) : %s" % [chat_message.nickname, chat_message.time, chat_message.message]
		chat_table.text += formatted_message + "\n"
		chat_table.scroll_vertical = chat_table.get_line_count()
	else:
		pass

# --- Function reading player input for sending
func _input (event : InputEvent) -> void:
	if (Input.is_action_just_pressed("send")):
		Send_message()
