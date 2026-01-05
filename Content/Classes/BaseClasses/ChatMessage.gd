class_name ChatMessage
var session  	: int
var nickname 	: String
var message  	: String
var time	 	: String

static func create (
	session 	: int, 
	nickname 	: String, 
	message 	: String,
	time 		: String
):
	var chat_message = ChatMessage.new()
	chat_message.session 	= session
	chat_message.nickname 	= nickname
	chat_message.message 	= message
	chat_message.time 		= time
	return chat_message
