extends MeshInstance3D

class_name  Button3D

@export var HilightMat := 0
@export var HilightEmission := Color(0.96, 0.805, 0.413, 1.0)
@export var HilightStrength := .5

@export_enum("Button", "Lever", "Switch") var AnimationType := "Button"
@export var AnimationDuration := 0.2
@export var AnimationCurve : Curve

var toggled := false
var anim := 0.0

var ogpos : Vector3
var ogrot : Vector3

var highlighted := false

func _ready():
	ogpos = position
	ogrot = rotation
	
func _process(delta):
	anim += delta
	anim = clamp(anim, 0, AnimationDuration)
	var progress = anim / AnimationDuration
	var halfprogress = 1.0 - abs(progress * 2.0 - 1.0)
	if AnimationType == "Button":
		position = lerp(ogpos, ogpos + Vector3(0,-0.1,0), halfprogress)
	elif AnimationType == "Lever":
		rotation = lerp(ogrot, ogrot + Vector3(0, 0, -PI / 2), halfprogress)
	elif AnimationType == "Switch":
		var from = ogrot if toggled else ogrot + Vector3(0, PI / 9, 0)
		var to = ogrot + Vector3(0, PI / 9, 0) if toggled else ogrot
		rotation = lerp(from, to, progress)

func set_highlight(on):
	highlighted = on
	
	var mat = get_active_material(HilightMat)
	mat.emission_enabled = on
	mat.emission = HilightEmission
	mat.emission_energy = HilightStrength

func press():
	print("Button pressed!: ", name)
	anim = 0
	if AnimationType == "Switch":
		toggled = !toggled
		
