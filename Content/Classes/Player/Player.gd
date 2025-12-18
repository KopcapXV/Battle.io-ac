extends CharacterBody2D

class_name Player

signal _on_health_changed	(new_value)
signal _on_mana_changed		(new_value)
signal _on_ability_used		(cooldown_time)
signal _on_player_died		()

var for_animation_object 

var for_collision_object 

var stat_speed 	: float = 150

var stat_health : float = 100

var stat_mana 	: float = 100

var current_health : float 

var current_mana : float

func _ready ():
	for_animation_object = $AnimatedSprite2D
	for_collision_object = $CollisionShape2D
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
