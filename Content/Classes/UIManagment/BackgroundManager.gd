extends AnimatedSprite2D

@export var background_idles : Array [String] = ["idle_1", "idle_2", "idle_3"]

func _ready () -> void:
	Play_next_random_idle()

func Play_next_random_idle () -> void:
	var next_idle_name : String = background_idles[randi() % background_idles.size()]
	play(next_idle_name)

func _on_animation_finished():
	#await get_tree().create_timer(0.5).timeout
	Play_next_random_idle()
