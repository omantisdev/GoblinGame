class_name DBG extends Node

static var _current_stat_priority: int = 0
## Draws text to the stat panel
static func draw_stat(stat_key: String, stat_value: Variant, text_group: StringName = 'default', text_color: Color = Color.YELLOW):
	DebugDraw2D.begin_text_group(text_group, 0, Color.YELLOW, true)
	DebugDraw2D.set_text(stat_key, stat_value, _current_stat_priority, text_color)
	DebugDraw2D.end_text_group()

	_current_stat_priority += 1
