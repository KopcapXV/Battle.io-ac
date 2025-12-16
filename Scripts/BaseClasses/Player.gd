extends CharacterBody2D

class_name Player

var for_animation_object 

var for_collision_object 

var stat_speed 	: float = 300


func _ready ():
	for_animation_object = $AnimatedSprite2D
	for_collision_object = $CollisionShape2D
