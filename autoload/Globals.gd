extends Node
## Session-wide state shared by every screen.

enum ClassType { TALL, SHORT }

const CLASS_NAMES := { ClassType.TALL: "TALL", ClassType.SHORT: "SHORT" }
const CLASS_TITLES := {
	ClassType.TALL: "TALL CLASS",
	ClassType.SHORT: "SHORT CLASS",
}
const CLASS_COLORS := {
	ClassType.TALL: Color("e8a33d"),
	ClassType.SHORT: Color("46c6a5"),
}
const MAX_PLAYERS := 12

var player_name := "Player"
var my_class := ClassType.TALL


func _ready() -> void:
	_setup_input()


func _setup_input() -> void:
	var defs := {
		"move_forward": [KEY_W, KEY_UP],
		"move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"sprint": [KEY_SHIFT],
		"jump": [KEY_SPACE],
		"crouch": [KEY_CTRL],
		"interact": [KEY_E],
		"backbreaker": [KEY_B],
		"boost": [KEY_F],
		"pause": [KEY_ESCAPE],
	}
	for action in defs:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		else:
			InputMap.action_erase_events(action)
		for key in defs[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)
