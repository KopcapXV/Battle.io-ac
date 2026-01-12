extends Node

class_name GameHUD

@export var health_bar : ProgressBar
@export var damage_bar : ProgressBar

@export var mana_bar   : ProgressBar
@export var leak_bar   : ProgressBar
		
@export var ability_cooldown : TextureProgressBar
@export var ability_icon 	 : TextureRect

var health_tween : Tween

func _ready () -> void:
	ability_cooldown.value = 0
	Signals.PlayerDamaged.connect(Update_health_bar)
	if ThisClient.selected_character == "Тихий":
		ability_icon.texture = preload("res://Content/Assets/UI/Ability_Quiet_1.png")
	else:
		ability_icon.texture = preload("res://Content/Assets/UI/Ability_Bloodweaver_1.png")

# --- Function for initializaing HUD's health bar
func Initialize_HUD (
	stat_health 	: float, 
	current_health 	: float,
	stat_mana 		: float,
	current_mana	: float
) -> void:
	health_bar.max_value 	= stat_health
	health_bar.value 		= current_health
	damage_bar.max_value 	= stat_health
	damage_bar.value 		= current_health
	mana_bar.max_value 		= stat_mana
	mana_bar.value 			= current_mana
	leak_bar.max_value 		= stat_mana
	leak_bar.value 			= current_mana
	print("HUD INITIALIZED", stat_health, stat_mana)

# --- Function for updating values of HUD's health bar
func Update_health_bar (id : int, new_health : int, damage : int) -> void:
	if id == CLIENT.globalId:
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
