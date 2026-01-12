class_name ChatMessage
var nickname 	: String
var message  	: String
var time	 	: String

static func create (
	nickname 	: int, 
	message 	: String,
	time 		: String
):
	var chat_message = ChatMessage.new()
	chat_message.nickname 	= "player" + str(nickname)
	chat_message.message 	= message
	chat_message.time 		= time
	return chat_message
