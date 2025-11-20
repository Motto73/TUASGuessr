@tool
extends MeshInstance3D

@export var play : bool = false
@export var imagess : Array[Texture2D]

var index = 0
var maxcount = 0

var timer := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if play:
		timer += delta
		if timer >= 0.05:
			get_surface_override_material(0).set("shader_parameter/Text", get_next_image())
			timer = 0
	
func get_next_image():
	index += 1
	if index >= len(imagess):
		index = 0
	return imagess[index]
