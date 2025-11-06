@tool
extends Node3D

class_name MapMarker

##Name of this specific data point. Optional but might help in debugging
@export var ImageName : String = ""
##The actual image texture of this data point. Simply drag it here is press "quick load"
@export var Picture : CompressedTexture2D 
##The difficulty of this point. Idk man 
@export_enum("easy", "medium", "hard", "impossible") var Difficulty : String = "easy"

@onready var preview : Sprite3D = $Preview

func _ready():
	if Engine.is_editor_hint():
		var editor_selection = EditorInterface.get_selection()
		editor_selection.selection_changed.connect(_on_selection_changed)
		_on_selection_changed()

func _on_selection_changed():
	var editor_selection = EditorInterface.get_selection()
	var is_selected = editor_selection.get_selected_nodes().has(self)
	preview.texture = Picture
	preview.visible = is_selected;
