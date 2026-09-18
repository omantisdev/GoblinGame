class_name World extends Node

const BASE_XP: float = 1000.0
const GROWTH_EXPONENT: float = 1.05
const MAX_LEVEL: int = 99

## The player's total XP
var xp: float = 0.0

var tick_timer: Timer
var tick_rate: float = 1.0

## Total XP required to reach a specific Level
## XP = Base XP * (Level - 1) ^ Growth Factor
func get_xp_for_level(level: int) -> int:
	if level <= 1: return 0
	return floor(BASE_XP * pow(level - 1, GROWTH_EXPONENT))

## Calculate exact Level from total lifetime XP
## Level = Math.floor(Math.log(Total_XP/Base_XP)/Math.log(Growth_Factor))+1
func get_level_from_xp(total_xp: int) -> int:
	if total_xp < BASE_XP: return 1
	
	var _level: float = log(total_xp / float(BASE_XP)) / log(GROWTH_EXPONENT)
	var integer_level: int = floor(_level) + 1
	
	return min(integer_level, MAX_LEVEL)
 
func _ready() -> void:
	## Tick Timer
	tick_timer = Timer.new()
	tick_timer.wait_time = tick_rate
	tick_timer.one_shot = false
	tick_timer.autostart = true
	tick_timer.timeout.connect(_tick)
	add_child(tick_timer)

func _tick() -> void:
	print("tick!")

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
