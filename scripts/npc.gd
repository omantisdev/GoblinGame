class_name NPC extends CharacterBody3D

#===== TODO ======
# State Machine
# Navigation
# Interaction
# Dialogue Trees
# Quest Trees
# Job System
#================

## State
enum State { IDLE, WANDER, TRAVEL, INTERACT };
var state: State = State.IDLE: set = set_state
func _handle_state(_state: State) -> void:
	match _state:
		State.IDLE: _on_idle()
		State.WANDER: _on_wander()
		State.INTERACT: _on_interact()
		State.TRAVEL: _on_travel()
func set_state(new_state: State) -> void:
	if state == new_state: return
	_handle_state(state)

@onready var _sprite: AnimatedSprite3D = $Sprite

## Animation
var idle_animations: Array[StringName] = []
var walk_animations: Array[StringName] = []

## Pathfinding
var current_target: Vector3 = Vector3.ZERO
var query_parameters := NavigationPathQueryParameters3D.new()
var query_result := NavigationPathQueryResult3D.new()

func query_path(origin: Vector3, target: Vector3, nav_layers: int = 1) -> PackedVector3Array:
	if not is_inside_tree():
		return PackedVector3Array()

	var map: RID = get_world_3d().get_navigation_map()

	if NavigationServer3D.map_get_iteration_id(map) == 0:
		return PackedVector3Array()
	
	query_parameters.map = map
	query_parameters.start_position = origin
	query_parameters.target_position = target
	query_parameters.navigation_layers = nav_layers

	NavigationServer3D.query_path(query_parameters, query_result)
	var path: PackedVector3Array = query_result.get_path()

	return path

func draw_path(path: PackedVector3Array) -> void:
	for point in path:
		DebugDraw3D.draw_sphere(point, 0.25, Color.YELLOW)
		
func _ready() -> void:
	if _sprite and _sprite.sprite_frames:
		for anim_name in _sprite.sprite_frames.get_animation_names():
			if anim_name.to_lower().contains("idle"):
				idle_animations.append(anim_name)
			if anim_name.to_lower().contains("walk"):
				walk_animations.append(anim_name)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_TAB:
			if state == State.IDLE: set_state(State.WANDER)
			if state == State.WANDER: set_state(State.TRAVEL)
			if state == State.TRAVEL: set_state(State.IDLE)

func _on_idle() -> void:
	var r = idle_animations[randi_range(0, idle_animations.size() - 1)]
	_sprite.play(r)

func _on_wander() -> void:
	var r = walk_animations[randi_range(0, walk_animations.size() - 1)]
	_sprite.play(r)

func _on_travel() -> void:
	var path = query_path(global_position, current_target)	
	if path:
		draw_path(path)
		var r = walk_animations[randi_range(0, walk_animations.size() - 1)]
		_sprite.play(r)
	
func _on_interact() -> void:
	pass
