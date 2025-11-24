extends Node3D

class_name  Map3D

@export var CanMove := false
@export var CanPlace := false
@export var ScrollSpeed := 1.0
@export var RotateSpeed := 1.0
@export var MoveSpeed := 1.0
@export var ClickVSDrag = 0.1

@onready var pivot := $Pivot
@onready var cam := $Pivot/Camera3D
@onready var markerstart := $MarkerStart
@onready var markerend := $MarkerEnd
@onready var drawline := $DrawLine

@onready var subview : SubViewport = $".."

@onready var mapdisplay : MapDisplay = $"../../../../.."

var mousedelta : Vector2
var scrolldelta : float
var dragrotate := false
var dragmove := false
var dragtimer := 0.0

var currentfloor
var floors : Array

func _ready():
	floors = [$MapAssets/ICT3,$MapAssets/ICT2,$MapAssets/ICT1,$MapAssets/ICT0,$MapAssets/EDU3,$MapAssets/EDU2,$MapAssets/EDU1]
	show_floor(1)

func _process(delta):
	if CanMove:
		cam.position.y += scrolldelta
		scrolldelta = 0
		if dragrotate:
			pivot.rotate(Vector3.UP, -mousedelta.x)
			#pivot.rotate(cam.global_transform.basis.x, -mousedelta.y)
			mousedelta = Vector2.ZERO
		elif dragmove:
			var right = pivot.global_transform.basis.x
			var up = cam.global_transform.basis.z * -1
			up = Vector3(up.x, 0, up.z).normalized()
			pivot.global_translate(-right * mousedelta.x * MoveSpeed)
			pivot.global_translate(up * mousedelta.y * MoveSpeed)
			mousedelta = Vector2.ZERO
	if dragrotate:
		dragtimer += delta
	else:
		if dragtimer > 0 and dragtimer < ClickVSDrag and CanMove:
			place()
		dragtimer = 0

#TODO - Use abstract input and handle mobile vs mouse elsewhere / UNLESS...?
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

func place():
	if mapdisplay.state != "input" and mapdisplay.state != "ready":
		return
	var mouse = subview.get_mouse_position()
	var pos = cam.project_ray_origin(mouse)
	var dir = cam.project_ray_normal(mouse)
	var spst = subview.world_3d.direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = pos
	params.to = pos + dir * 1000
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var result := spst.intersect_ray(params)
	if result:
		markerstart.visible = true
		markerstart.position = result.position
		mapdisplay.update_guess(result.position)
	else:
		print("missed")

func reveal():
	markerstart.visible = true
	markerend.visible = true
	var pos = mapdisplay.actualPoint.position
	pos.y = 0
	markerend.position = pos
	
	drawline.visible = true
	drawline.position = markerstart.position + (markerend.position - markerstart.position) * 0.5
	drawline.look_at(markerend.position)
	drawline.scale = Vector3(0.1, 0.1, (markerend.position - markerstart.position).length())
	
func reset():
	markerstart.visible = false
	markerend.visible = false
	drawline.visible = false

func lock():
	CanMove = false

func show_floor(num):
	currentfloor = num
	for i in len(floors):
		floors[i].visible = floors[i].name.ends_with(str(num))
