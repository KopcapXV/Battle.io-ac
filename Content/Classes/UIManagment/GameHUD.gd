extends Node

class_name GameHUD

@onready var health_bar 		= $Control/HealthBar
@onready var damage_bar 		= $Control/DamageBar
@onready var ability_cooldown 	= $Control/AbilityIcon/AbilityCooldown

var health_tween : Tween

func _ready () -> void:
	ability_cooldown.value = 0

# --- Function for initializaing HUD's health bar
func Init_health_bar (stat_health : float, current_health : float) -> void:
	health_bar.max_value = stat_health
	health_bar.value = current_health
	damage_bar.max_value = stat_health
	damage_bar.value = current_health

# --- Function for updating values of HUD's health bar
func Update_health_bar (new_health) -> void:
	var old_health = health_bar.value
	health_bar.value = new_health
	
	if new_health < old_health:
		if (health_tween):
			health_tween.kill()
			
		health_tween = create_tween()
		health_tween.tween_interval(0.1)
		health_tween.tween_property(damage_bar, "value", new_health, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	else:
		damage_bar.value = new_health
	
# --- Function to start cooldowmn of HUD's ability
func Start_cooldown (time : float) -> void:
	ability_cooldown.max_value = time
	ability_cooldown.value = time
	
	var tween = create_tween()
	tween.tween_property(ability_cooldown, "value", 0.0, time).set_trans(Tween.TRANS_LINEAR)
