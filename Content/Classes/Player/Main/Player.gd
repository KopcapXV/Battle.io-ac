extends CharacterBody2D

class_name Player

signal _on_player_spawned 	()
signal _on_health_changed	(new_value)
signal _on_mana_changed		(new_value)
signal _on_ability_used		(cooldown_time)
signal _on_player_died		()

@export var for_animation_object : AnimatedSprite2D

@export var for_collision_object : CollisionShape2D

var stat_speed 	: float = 150

var stat_health : float = 100

var stat_mana 	: float = 100

var current_health : float 

var current_mana : float

var id : int = 111

var state_move : StateMove

func _ready ():
	var state_machine : Node = preload("uid://18clg5181kcm").instantiate()
	var camera : Node = Camera2D.new()
	add_child(state_machine)
	add_child(camera)
	camera.zoom.x = 2
	camera.zoom.y = 2
	add_to_group("Player")
	
	state_move = get_node("StateMachine/StateMove")

	current_health = stat_health
	current_mana = stat_mana

func Take_damage (damage_amount : float) -> void:
	current_health -= damage_amount
	current_health = clamp(current_health, 0, stat_health)
	_on_health_changed.emit(current_health)
	
func Heal (heal_amount : float) -> void:
	current_health += heal_amount
	current_health = clamp(current_health, 0, stat_health) 
	_on_health_changed.emit(current_health)
	
func Die () -> void:
	_on_player_died.emit()


func _input(event) -> void:
	if (event.is_action_pressed("take")):
		Take_damage(10)
