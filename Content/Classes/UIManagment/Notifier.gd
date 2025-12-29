extends Control

class_name Notifier

@export var notification_label 		: Label
@export var notification_animator : AnimationPlayer

func _ready () -> void:
	self.visible = false
	if notification_animator:
		notification_animator.animation_finished.connect(_on_animation_player_animation_finished)
		

func _input(event) -> void:
	if (event.is_action_pressed("notify")):
		Send_notification("hello")

# --- Function to visualize the notification for the player
func Send_notification (notification_message : String) -> void:
	notification_label.text = notification_message
	Show_notifier()
	
# --- Function to show player the notifier
func Show_notifier () ->  void:
	self.visible = true
	notification_animator.play("show")
	
	await get_tree().create_timer(3.0).timeout
	Hide_notifier()
	
func Hide_notifier () -> void:
	notification_animator.play("hide")
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hide":
		self.visible = false
