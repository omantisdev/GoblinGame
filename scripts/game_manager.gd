class_name GameManager extends Node

var game_time: float = 0.0

func _tick() -> void:
	game_time += 1.0
	pass

# Unfixed Time Step
func _process(delta: float) -> void:
	DBG.draw_stat("delta", delta)
	pass

# Fixed Time Step
func _physics_process(delta: float) -> void:
	# Set global time	
	pass
