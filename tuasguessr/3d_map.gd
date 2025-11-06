extends Node3D

@export var CanMove := false
@export var CanPlace := false
@export var ScrollSpeed := 1.0
@export var RotateSpeed := 1.0
@export var MoveSpeed := 1.0

@onready var pivot := $Pivot
@onready var cam := $Pivot/Camera3D

var mousedelta : Vector2
var scrolldelta : float
var dragrotate := false
var dragmove := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if CanMove:
		cam.position.y += scrolldelta
		scrolldelta = 0
		if dragrotate:
			pivot.rotate(cam.global_transform.basis.y, -mousedelta.x)
			pivot.rotate(cam.global_transform.basis.x, -mousedelta.y)
			mousedelta = Vector2.ZERO
		elif dragmove:
			var right = cam.global_transform.basis.x
			var up = cam.global_transform.basis.y
			cam.global_translate(-right * mousedelta.x * MoveSpeed)
			cam.global_translate(up * mousedelta.y * MoveSpeed)
			mousedelta = Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scrolldelta -= ScrollSpeed * 0.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scrolldelta += ScrollSpeed * 0.1
		elif event.button_index == MOUSE_BUTTON_LEFT:
			dragrotate = event.pressed
		elif event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			dragmove = event.pressed && not dragrotate
	elif  event is InputEventMouseMotion:
		mousedelta = (event as InputEventMouseMotion).relative * RotateSpeed * 0.01
