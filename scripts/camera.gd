@icon("res://addons/at-icons/node3d/video_camera.svg")
extends Node3D

@export_category("Camera")
@export var pan_speed: float = 12.0
@export var pan_smoothing: float = 8.0
@export var zoom_speed: float = 1.0

@export_category("Spring Arm")
@export var arm_length: float = 12.0
@export var lerp_speed: float = 6.0
@export var target: CharacterBody3D
@export_range(0.0, 1.0) var mouse_sensitivity = 0.01
@export_range(0.0, 90.0) var tilt_angle: float = 15.0

@export_category("Misc")
@export var draw_debug: bool = false

@onready var spring_arm: SpringArm3D = $SpringArm

var camera_pivot: Node3D

enum State {
	FIXED,
	FOLLOWING,
	INTERACTING
}
var state: State = State.FIXED

func _ready() -> void:
	if spring_arm:
		spring_arm.spring_length = arm_length
		spring_arm.collision_mask = 1
		spring_arm.rotate_x(deg_to_rad(-tilt_angle))
	if target:
		state = State.FOLLOWING
		
func _physics_process(delta: float) -> void:
	match(state):
		State.FIXED:
			pass
		State.FOLLOWING:
			_pan(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event and event.is_action("camera_zoom_in"):
		spring_arm.spring_length -= 1.0
	if event and event.is_action("camera_zoom_out"):
		spring_arm.spring_length += 1.0
		
func _pan(delta: float) -> void:		
	if target == null: return
	global_position.x = target.position.x
	global_position.y = target.position.y
	
	var xform = _align_vertical(global_transform, target.global_basis.y)
	global_transform = global_transform.interpolate_with(xform, lerp_speed * delta)

func _align_vertical(xform, new_y) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
