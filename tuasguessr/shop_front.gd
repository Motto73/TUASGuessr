extends Node3D

class_name  Shopfront

@onready var animator := $AnimationPlayer
@onready var sellerguy := $"Armature/Skeleton3D/Seller man guy"
@onready var subview := $".."
@onready var cam := $Camera3D

var face_normal = preload("res://Assets/Textures/face_normal.png")
var face_joy = preload("res://Assets/Textures/face_joy.png")
var face_angry = preload("res://Assets/Textures/face_angry.png")
var face_suprise = preload("res://Assets/Textures/face_surprise.png")
var face_mat : Material

var isvisible := false
var saidhello := false

var idles = ["Idle_0", "Idle_1", "Idle_2"]
var idleboreds = ["Idle_Bored_0", "Idle_Bored_1", "Idle_Bored_2", "Idle_Bored_3"]
var idlerares = ["Idle_Rare_0"]
var yippees = ["Yippee_0", "Yippee_1"]

var exp_angries = ["Slide_R", "Slide_L"]
var exp_happies = ["Yippee_0", "Yippee_1", "Hello_0"]
var exp_normals = ["Idle_0", "Idle_1", "Idle_2", "Idle_Bored_0", "Idle_Bored_1", "Idle_Bored_2", "Idle_Bored_3", "Idle_Rare_0"]

# Called when the node enters the scene tree for the first time.
func _ready():
	face_mat = sellerguy.get_surface_override_material(1) as Material
	face_mat.albedo_texture = face_normal
	animator.animation_finished.connect(_on_animation_finished)
	animator.animation_started.connect(_on_animation_started)

func _process(delta):
	if !animator.is_playing():
		queue_anim(randomidle())
	
func play_anim(name):
	animator.play(name)

func queue_anim(name):
	#animator.clear_queue()
	animator.queue(name)

func _on_animation_finished(name):
	if name == "Slide_R" && !saidhello:
		queue_anim("Hello_0")
		saidhello = true

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


func _on_animation_started(name):
	if exp_angries.has(name):
		face_mat.albedo_texture = face_angry
	elif exp_happies.has(name):
		face_mat.albedo_texture = face_joy
	elif exp_normals.has(name):
		face_mat.albedo_texture = face_normal

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if !isvisible:
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
			var result = spst.intersect_ray(params)
			if result:
				play_anim(randfrom(yippees))
