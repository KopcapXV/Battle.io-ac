extends Node2D

@export var menu_matchmaking : Control
@export var menu_ingame_ui	 : CanvasLayer


func _ready () -> void:
	CLIENT.get_room()
	#CLIENT.accept_session()
	Global.GameStateIsStop.connect(Navigate_to_menu)
	Global.GameStateIsPlay.connect(Navigate_to_arena)
	
	await get_tree().create_timer(randi_range(15, 25)).timeout
	#WEBSOCKET.send_string(WEBSOCKET.SEND_COMMAND.MESSAGE, "Hellloooo!!!!")
	
func Navigate_to_arena () -> void:
	menu_matchmaking.visible = false
	menu_ingame_ui.visible = true
	
func Navigate_to_menu  () -> void:
	get_tree().change_scene_to_file("res://Content/UI/UISegment.tscn")
	menu_matchmaking.visible = true
	menu_ingame_ui.visible = false
