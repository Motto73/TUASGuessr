extends Node3D

class_name Slots3D

@export var RotateTime := 1.0
@export var MoveCurve : Curve

@onready var pivot := $Pivot
@onready var cam := $Pivot/Camera3D

@onready var shopswitch := $SlopMachine/Switch
@onready var buttonleft := $SlopMachine/Button_Left
@onready var buttonring := $SlopMachine/Button_Right
@onready var lever := $SlopMachine/Lever
@onready var subview := $".."

var show_shop := false
var selection : Button3D

var movetimer := 0.0
var movestart : Vector3
var moveend : Vector3
var moverot  : float
var moverotend : float
var movecam : Vector3
var movezoom : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	movestart = pivot.position
	moveend = Vector3(0, -2.6, 0)
	moverot = pivot.rotation.y
	moverotend = moverot + PI / 2
	movecam = cam.position
	movezoom = movecam + Vector3(-3,0,-0.2)


func _process(delta):
	if show_shop:
		movetimer += delta
	else :
		movetimer -= delta
	movetimer = clamp(movetimer, 0, RotateTime)
	var progress = movetimer / RotateTime
	pivot.position = lerp(movestart, moveend, MoveCurve.sample(progress))
	pivot.rotation.y = lerp_angle(moverot, moverotend, MoveCurve.sample(progress))
	cam.position = lerp(movecam, movezoom, MoveCurve.sample(progress))

func _physics_process(_delta):
	var ray = raycast()
	if ray:
		var obj = ray.collider.get_parent()
		if obj is Button3D:
			select_this_shit_right_now_or_actually_unselect_it_if_you_want_to_im_not_telling_you_what_to_do(obj, true)
	else:
		select_this_shit_right_now_or_actually_unselect_it_if_you_want_to_im_not_telling_you_what_to_do(null, false)
		
func select_this_shit_right_now_or_actually_unselect_it_if_you_want_to_im_not_telling_you_what_to_do(target, add):
	if add:
		selection = target as Button3D
		selection.set_highlight(true)
	else:
		if selection:
			selection.set_highlight(false)
		selection = null

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			lit(false)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			lit(true)
		elif event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var cast = raycast()
			if cast && cast.collider.get_parent() is Button3D:
				(cast.collider.get_parent() as Button3D).press()

func raycast() -> Dictionary:
	var mouse = subview.get_mouse_position()
	var pos = cam.project_ray_origin(mouse)
	var dir = cam.project_ray_normal(mouse)
	var spst = get_viewport().world_3d.direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = pos
	params.to = pos + dir * 1000
	params.collide_with_areas = true
	params.collide_with_bodies = true
	var result = spst.intersect_ray(params)
	return result

func lit(on):
	show_shop = on
