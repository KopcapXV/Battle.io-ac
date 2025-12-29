extends Control

class_name UIManager

# -- UI-signals
signal _menu_show 	(menu_key : String, menu_node : Control)
signal _menu_hide 	(menu_key : String, menu_node : Control)
signal _menu_shown 	(menu_key : String, menu_node : Control)
signal _menu_hidden (menu_key : String, menu_node : Control)

# -- Dictionary of UI-sections
var menus : Dictionary = { }
# -- State of the section of UI-Menu (current section)
var menu_current : Control = null
# -- State of the Label
var label_current : Node = null
# -- Export variables for Menu UI Control nodes 
@export var menu_section_main 		 : Control
@export var menu_section_settings 	 : Control
@export var menu_section_leaderboard : Control
@export var menu_label 				 : Control
# -- Export animators for Menu
@export var animator_main			 : AnimationPlayer
@export var animator_settings		 : AnimationPlayer
@export var animator_leaderboard	 : AnimationPlayer


func _ready () -> void:
	# Switch off all sections
	Register_menu("MAIN", 		 menu_section_main)
	Register_menu("SETTINGS", 	 menu_section_settings)
	Register_menu("LEADERBOARD", menu_section_leaderboard) 
	
	menu_label.text = "ГЛАВНОЕ МЕНЮ"
	
	for menu in menus.values():
		menu.visible = false
	Show_menu("MAIN")


# --- Function for registrating a section in menus dictionary
# makes section one of the UIManager's sections
func Register_menu (menu_key : String, menu_node : Control) -> void:
	menus[menu_key] = menu_node
	menu_node.visible = false


# --- Function for turning visibility of  specified the section
func Show_menu (menu_key : String) -> void:
	# - Check existence of the section
	if (not menus.has(menu_key)):
		push_warning("<UIManager> : Unkown menu %s" % menu_key)
		return
	# - Switch menus 
	if (menu_current):
		menu_current.visible = false
	menu_current = menus[menu_key]
	if (menu_current):
		menu_current.visible = true


# --- Signals for pressing the buttons
# --- Handler of quickplay button
func _on_quickplay_pressed():
	get_tree().change_scene_to_file("res://Content/Scenes/TestScene.tscn")
# --- Handler of settings button

func _on_settings_pressed():
	Show_menu("SETTINGS")
	menu_label.text = "НАСТРОЙКИ"
# --- Handler of leaderboard button

func _on_leaderboard_pressed():
	Show_menu("LEADERBOARD")
	menu_label.text = "ЛИДЕРЫ"
# --- Handler of back button

func _on_back_pressed():
	Show_menu("MAIN")
	menu_label.text = "ГЛАВНОЕ МЕНЮ"
