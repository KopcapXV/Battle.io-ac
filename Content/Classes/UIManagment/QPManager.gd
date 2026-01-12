extends Control

var characters : Array [Dictionary] = []
var current_index : int = 0
var selected_character : String
@export var character_image : TextureRect 
@export var character_label : Label
@export var previous_button : Button
@export var next_button 	: Button
@export var select_button 	: Button


func _ready () -> void:
	Load_characters()
	Update_QP_display()
	previous_button.pressed.connect(Get_previous_character)
	next_button.pressed.connect(Get_next_character)
	select_button.pressed.connect(Select_character)
	
func Load_characters () -> void:
	characters = [
		{
			"name": "Тихий", 
			"texture": preload("res://Content/Assets/Characters/Assasins/Quiet/quiet_sprite.png")
		},
		{
			"name": "Прядильщик", 
			"texture": preload("res://Content/Assets/Characters/Tanks/Bloodweaver/Bloodweaver_sprite.png")
		}
	]
	
func Update_QP_display () -> void:
	var character = characters[current_index]
	character_image.texture = character.texture
	character_label.text = character.name
	
func Get_previous_character () -> void:
	current_index = wrapi(current_index - 1, 0, characters.size())
	Update_QP_display()
	
func Get_next_character () -> void:
	current_index = wrapi(current_index + 1, 0, characters.size())
	Update_QP_display()
	
func Select_character () -> void:
	selected_character = characters[current_index].name
	ThisClient.selected_character = selected_character
	print("<QPManager> : Character selected ", selected_character)
	get_tree().change_scene_to_file("res://Content/Scenes/TestScene.tscn")
