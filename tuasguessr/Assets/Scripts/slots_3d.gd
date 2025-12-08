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

@onready var led_display : LedDisplay = $SlopMachine/Display

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
	moveend = Vector3(0.05, -2.45, -1.5)
	moverot = pivot.rotation.y
	moverotend = moverot + PI / 2
	movecam = cam.position
	movezoom = movecam + Vector3(-3,0,-0.2)
	#Slot setup
	state = "ready"
	set_random_images()
	#Shop setup
	print(sellerguy)
	face_mat = sellerguy.get_active_material(1) as Material
	face_mat.albedo_texture = face_normal
	animator.animation_finished.connect(_on_animation_finished)
	animator.animation_started.connect(_on_animation_started)


func _process(delta):
	if Game.Active.actualGame.inventorytags.has("shoe"):
		delta *= 10.0
		#Speed up roulette sound
		Sounds.set_roulette_sound_speed(5.0)
	#Process slots
	process_slots(delta)
	#Process shop
	process_shop(delta)
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
		if obj is ShopItem:
			set_description(obj)
	else:
		select_this_shit_right_now_or_actually_unselect_it_if_you_want_to_im_not_telling_you_what_to_do(null, false)
		set_description(null)

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
			if cast and cast.collider.get_parent() is ShopItem:
				var si = cast.collider.get_parent()
				if Game.Active.actualGame.buy_item(si):
					si.queue_free()
					play_anim(randfrom(yippees))

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

var gold := false
func select_point():
	gold = false
	$SlopMachine/Machine.set_surface_override_material(0, load("res://Assets/Materials/mat_slop_purple.tres"))
	var rand = rng.randi_range(0, len(Data.DataPoints) - 1)
	selectedIMG = load(Data.DataPoints[rand].imgresource)
	selectedPoint = Data.DataPoints[rand]
	Game.Active.actualGame.set_datapoint(selectedPoint)
	gold = rng.randf() > 0.8 and Game.Active.actualGame.inventorytags.has("gold")
	if gold:
		Game.Active.actualGame.set_gold()
		$SlopMachine/Machine.set_surface_override_material(0, load("res://Assets/Materials/mat_slop_gold.tres"))
	$"../../..".set_sparkle(gold)

func prepare_slices():
	return
	
	#for slice in hub.get_children():
		#var newmat := ShaderMaterial.new()
		#var newshader := load("res://Assets/Materials/cut.gdshader")
		#newmat.shader = newshader
		#slice.set_surface_override_material(1, newmat)

func show_all_random():
	for i in range(hub.get_child_count()):
		if i != 0:
			show_random_image(i)
		else:
			show_specific_image(0, load("res://Assets/Textures/Blackpixel.png"))

func show_random_image(slot):
	var rand = rng.randi_range(0, len(images) - 1)
	var part = hub.get_children()[slot] as MeshInstance3D
	(part.get_surface_override_material(1) as ShaderMaterial).set_shader_parameter("image", images[rand])

func show_specific_image(slot, image):
	var part = hub.get_children()[slot] as MeshInstance3D
	(part.get_surface_override_material(1) as ShaderMaterial).set_shader_parameter("image", image)

func _on_roll_button_button_down():
	if state == "ready":
		Sounds.play_button_normal()
		state = "rolling"
		if state == "rolling":
			Sounds.play_roulette()
		timer = 0
		#TODO experiment
		select_point()
		led_display.set_roll()
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
		#The rolling sound should be stopped here
		if timer >= SpinTime:
			state = "gaming"
			timer = 0
			Sounds.stop_roulette_sound()
			Game.Active.actualGame.allow_bets()
			led_display.set_diff(selectedPoint.difficulty, gold)

#Shop behavior
@export_category("Shop")
@export var Slots : Array[Node3D]
@export var ItemData : ItemDataPoints

@onready var animator := $SlopMachine/AnimationPlayer
@onready var sellerguy := $"SlopMachine/Armature/Skeleton3D/Seller man guy"
@onready var shoptext := $SlopMachine/Shop/ShopPreview

var face_normal = preload("res://Assets/Textures/face_normal.png")
var face_joy = preload("res://Assets/Textures/face_joy.png")
var face_angry = preload("res://Assets/Textures/face_angry.png")
var face_suprise = preload("res://Assets/Textures/face_surprise.png")
var face_mat : Material

var empty := true
var isvisible := false
var saidhello := false

var idles = ["Idle_0", "Idle_1", "Idle_2"]
var idleboreds = ["Idle_Bored_0", "Idle_Bored_1", "Idle_Bored_2"]
var idlerares = ["Idle_Rare_0"]
var yippees = ["Yippee_0", "Yippee_1"]

var exp_angries = ["Slide_R", "Slide_L"]
var exp_happies = ["Yippee_0", "Yippee_1", "Hello_0"]
var exp_normals = ["Idle_0", "Idle_1", "Idle_2", "Idle_Bored_0", "Idle_Bored_1", "Idle_Bored_2", "Idle_Rare_0"]

func process_shop(delta):
	if !animator.is_playing():
		queue_anim(randomidle())
	if Game.Active.actualGame != null && empty:
		load_items()

#Shop animations
func play_anim(aname):
	animator.play(aname)

func queue_anim(aname):
	#animator.clear_queue()
	animator.queue(aname)

func _on_animation_finished(aname):
	if aname == "Slide_R" && !saidhello:
		queue_anim("Hello_0")
		saidhello = true
		
func _on_animation_started(name):
	if exp_angries.has(name):
		face_mat.albedo_texture = face_angry
	elif exp_happies.has(name):
		face_mat.albedo_texture = face_joy
	elif exp_normals.has(name):
		face_mat.albedo_texture = face_normal

func randomidle():
	var num = randf()
	if num <.2:
		return randfrom(idles)
	elif num < .95:
		return randfrom(idleboreds)
	else:
		return "Idle_Rare_0"

func randfrom(list):
	return list[randi_range(0, len(list) - 1)]

#Shop items
func load_items():
	print("-------------Shop items loading--------------")
	empty = false
	var items := []
	#Create a list of items that are allowed in the store
	for item in ItemData.Items:
		if not Game.Active.actualGame.inventorytags.has(item.tag):
			items.append(item)
	#Randomize
	Slots.shuffle()
	items.shuffle()
	#Clear slots
	for x in Slots:
		for y in x.get_children():
			y.queue_free()
	#Spawn items
	for i in len(Slots):
		if i >= len(items):
			break
		var slot = Slots[i]
		var item = items[i].scene.instantiate()
		slot.add_child(item)
		item.global_position = slot.global_position

func set_description(item):
	if item and item is ShopItem:
		var price = Game.Active.actualGame.adjust_price(item.Price)
		shoptext.text = item.name + "\nPrice: " + str(price) + "\n" + item.Description
	else:
		shoptext.text = ""
