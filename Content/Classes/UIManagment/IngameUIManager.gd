extends Control

@export var ingame_settings 	: Control
@export var ingame_menu 		: Control
@export var ingame_animator 	: AnimationPlayer

var ingame_menu_active : bool = false

func _ready () -> void:
	self.visible = false
	
	
func Trigger_ingame_menu () -> void:
	if ingame_animator.is_playing():
		return
	Toggle_ingame_menu_with_animation()


func Toggle_ingame_menu_with_animation () -> void:
	if (ingame_menu_active):
		ingame_animator.play("hide")	
	else:
		self.visible = true
		ingame_animator.play("show")
	ingame_menu_active = !ingame_menu_active
	
	
func _input (event) -> void:
	if (event.is_action_pressed("ingame")):
		Trigger_ingame_menu()		


func _on_back_button_pressed():
	Trigger_ingame_menu()


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("uid://bk2sw51iswc8e")
