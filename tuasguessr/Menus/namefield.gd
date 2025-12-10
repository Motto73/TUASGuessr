extends TextEdit

func _ready():
	focus_mode = Control.FOCUS_ALL

func _gui_input(event):
	if event is InputEventScreenTouch and event.pressed:
		grab_focus()
		if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
			DisplayServer.virtual_keyboard_show(text)
