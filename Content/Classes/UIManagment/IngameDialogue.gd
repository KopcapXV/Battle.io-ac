extends Control

func _ready () -> void:
	self.visible = false
	Signals.PlayerKilled.connect(Show_death_message)

func Show_death_message (id : int) -> void:
	if id == CLIENT.globalId:
		self.visible = true
