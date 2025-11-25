extends Node3D

class_name Slots3D

@export var MoveTime := 1.0
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

#Setup
func _ready():
	#Animation setup
	movestart = pivot.position
	moveend = Vector3(0, -2.5, 0)
	moverot = pivot.rotation.y
	moverotend = moverot + PI / 2
	movecam = cam.position
	movezoom = movecam + Vector3(-3,0,-0.2)
	#Slot setup
	state = "ready"
	set_random_images()


func _process(delta):
	#Process slots
	process_slots(delta)
	#Process moving the camera
	if show_shop:
		movetimer += delta
	else :
		movetimer -= delta
	movetimer = clamp(movetimer, 0, MoveTime)
	#Animations
	process_animations(delta)

func _physics_process(_delta):
	#Highlighting objects
	var ray = raycast()
	if ray:
		var obj = ray.collider.get_parent()
		if obj is Button3D:
			select_this_shit_right_now_or_actually_unselect_it_if_you_want_to_im_not_telling_you_what_to_do(obj, true)
	else:
		select_this_shit_right_now_or_actually_unselect_it_if_you_want_to_im_not_telling_you_what_to_do(null, false)

#Animations
func process_animations(delta):
	var progress = movetimer / MoveTime
	pivot.position = lerp(movestart, moveend, MoveCurve.sample(progress))
	pivot.rotation.y = lerp_angle(moverot, moverotend, MoveCurve.sample(progress))
	cam.position = lerp(movecam, movezoom, MoveCurve.sample(progress))
#All that is clicky and clacky
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
				if cast.collider.get_parent() == buttonleft or cast.collider.get_parent() == lever:
					_on_roll_button_button_down()
				if cast.collider.get_parent() == shopswitch or cast.collider.get_parent() == buttonring:
					lit(!show_shop)

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

#Slot behavior
@export_category("Slots")
@export var SpinTime : float = 2.0
@export var SpinAmount = 2
@export var SpinCurve : Curve
@export var RandomImagePoolSize := 10
@export var Data : MapDataPoints

@onready var rollbutton := $SlopMachine/Button_Left
@onready var hub := $SlopMachine/WheelHub

var selectedIMG 
var selectedPoint : MapDataPoint
var state : String = "loading"
var timer : float = 0
var images : Array = []
var rng := RandomNumberGenerator.new()

func set_random_images():
	images = []
	var num = 0
	var dp = Data.DataPoints
	dp.shuffle()
	for d : MapDataPoint in dp:
		var img = load(d.imgresource) as CompressedTexture2D
		images.append(img)
		num += 1
		if num >= RandomImagePoolSize:
			break
	print("Random images 3D set: ", len(images))
	show_all_random()
	
func lock():
	state = "locked"
	rollbutton.enable(false)
	lever.enable(false)
	timer = 0
	
func reset():
	rollbutton.enable(true)
	lever.enable(true)
	state = "ready"

func select_point():
	var rand = rng.randi_range(0, len(Data.DataPoints) - 1)
	selectedIMG = load(Data.DataPoints[rand].imgresource)
	selectedPoint = Data.DataPoints[rand]
	Game.Active.actualGame.set_datapoint(selectedPoint)

func prepare_slices():
	for slice in hub.get_children():
		var mat = slice.get_surface_override_material(1) as ShaderMaterial
		mat = mat.duplicate() as ShaderMaterial
		slice.set_surface_override_material(1, mat)

func show_all_random():
	for i in range(hub.get_child_count()):
		show_random_image(i)

func show_random_image(slot):
	var rand = rng.randi_range(0, len(images) - 1)
	var part = hub.get_children()[slot] as MeshInstance3D
	(part.get_surface_override_material(1) as ShaderMaterial).set_shader_parameter("image", images[rand])

func show_specific_image(slot, image):
	var part = hub.get_children()[slot] as MeshInstance3D
	(part.get_surface_override_material(1) as ShaderMaterial).set_shader_parameter("image", image)

func _on_roll_button_button_down():
	if state == "ready":
		state = "rolling"
		timer = 0
		#TODO experiment
		select_point()
	rollbutton.enable(false)
	lever.enable(false)
	Game.Active.actualGame.hide_map()

func process_slots(delta):
	if state == "rolling":
		timer += delta
		var progress= SpinCurve.sample(timer / SpinTime)
		hub.rotation = lerp(Vector3.ZERO, Vector3(0,0,SpinAmount * 2 * PI), progress)
		if progress > 0.5:
			show_specific_image(0, selectedIMG)
		if timer >= SpinTime:
			state = "gaming"
			timer = 0
			Game.Active.actualGame.allow_bets()
