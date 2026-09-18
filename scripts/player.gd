class_name Player extends CharacterBody3D

@export_group("Input")
@export_range(0.0, 1.0) var input_threshold := 0.01

@export_group("Movement")
@export var move_speed := 4.0
@export var move_threshold := 0.1
@export var rotation_smoothing := 12.0
@export_range(0.0, 1.0) var rotate_speed := 0.15

@export_group("Tweens")
@export var flip_duration: float = 0.60
@export var flip_trans = Tween.TRANS_BACK
@export var flip_ease = Tween.EASE_OUT

@export_group("Debug")
@export var _draw_debug: bool = false

@onready var _sprite: AnimatedSprite3D = $Sprite
@onready var _ground_ray: RayCast3D = $GroundRay

enum State {
	IDLE,
	MOVING,
	INTERACTING
}
var state := State.IDLE: set = set_state

var gravity: Vector3
var velocity_vert: float = 0.0
var velocity_horiz: float = 0.0

var _facing: Vector3 = Vector3.RIGHT
var _input: Vector2 = Vector2.ZERO
var _flip_tween: Tween = null

var current_collision: KinematicCollision3D

var idle_animations: Array[StringName] = []
var walk_animations: Array[StringName] = []

func set_state(new_state: State) -> void:
	if state == new_state: return
	state = new_state;
	handle_state(state)

func handle_state(_state: State):
	match _state:
		State.IDLE:
			var r = idle_animations[randi_range(0, idle_animations.size()-1)]
			_sprite.play(r)
		State.MOVING:
			var r = walk_animations[randi_range(0, walk_animations.size()-1)]
			_sprite.play(r)

func align_vertical(xform, new_y) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func flip_sprite(input_dir: Vector2) -> void:
	var v3 := Vector3(input_dir.x, 0.0, input_dir.y)
	var dot = _facing.dot(v3)
	if dot == -1.0 or dot == 1.0:
		_flip_tween = get_tree().create_tween().bind_node(_sprite)
		_flip_tween.set_ease(Tween.EASE_OUT)
		_flip_tween.set_trans(Tween.TRANS_SPRING)
		var angle = _facing.signed_angle_to(basis.x * dot, Vector3.UP)
		_flip_tween.tween_property(_sprite, "rotation:y", angle, flip_duration)

func _ready() -> void:
	DebugDraw3D.debug_enabled = _draw_debug
	gravity = get_gravity()

	if _sprite and _sprite.sprite_frames:
		for anim_name in _sprite.sprite_frames.get_animation_names():
			if anim_name.to_lower().contains("idle"):
				idle_animations.append(anim_name)
			if anim_name.to_lower().contains("walk"):
				walk_animations.append(anim_name)

	handle_state(state)
	
func _physics_process(delta: float) -> void:
	# Get player input
	_input = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	if _input.length_squared() > input_threshold:
		set_state(State.MOVING)
	else:
		set_state(State.IDLE)

	# handle vertical velocity
	if is_on_floor():
		velocity_vert = 0.0
	else:
		velocity_vert -= 9.8 * delta	

	# handle horizontal velocity
	var input_dir = Input.get_vector(&"player_left", &"player_right", &"player_forward", &"player_backward")
	velocity = (input_dir.x * basis.x + input_dir.y * basis.z) * move_speed

	# add vertical velocity to final velocity
	velocity += basis.y * velocity_vert
	move_and_slide()

	# set up direction so move_and_slide is not confused
	up_direction = global_basis.y
	flip_sprite(input_dir.normalized())

	# handle ground collisions
	if (_ground_ray.is_colliding()):
		var ground_normal = _ground_ray.get_collision_normal()
		var xform = align_vertical(global_transform, ground_normal)
		global_transform = transform.interpolate_with(xform, rotation_smoothing * delta)

	_debug_draw()

func _debug_draw() -> void:
	# Draw global basis vectors
	var pos = global_position
	DebugDraw3D.draw_arrow(pos, pos + global_basis.x, Color.RED, 0.25)
	DebugDraw3D.draw_arrow(pos, pos + global_basis.y, Color.YELLOW, 0.25)
	DebugDraw3D.draw_arrow(pos, pos + global_basis.z, Color.BLUE, 0.25)
