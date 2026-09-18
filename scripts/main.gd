@icon("res://addons/at-icons/node3d/hexagon.svg")
class_name Main extends Node

var world_scene = preload("res://scenes/world.tscn").instantiate()

@onready var gui: Control = $GUI
@onready var world: Node3D = $World

func _ready() -> void:
	world.add_child(world_scene)
	pass
