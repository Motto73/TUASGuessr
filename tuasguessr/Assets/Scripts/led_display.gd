extends MeshInstance3D

class_name  LedDisplay

var img_easy : Texture2D
var img_medium : Texture2D
var img_hard : Texture2D
var img_hard2 : Texture2D

var img_10 : Texture2D
var img_11 : Texture2D
var img_125 : Texture2D
var img_15 : Texture2D
var img_20 : Texture2D

var img_rand : Texture2D
var img_roll : Texture2D
var img_gold : Texture2D

var mat_big : ShaderMaterial
var mat_small : ShaderMaterial

var shake := false
var rollin := false
var offset1 := Vector2.ZERO
var offset2 := Vector2.ZERO

func _ready():
	#These are very small images so we just load them all
	img_easy = load("res://Assets/Textures/led_easy.png")
	img_medium = load("res://Assets/Textures/led_medium.png")
	img_hard = load("res://Assets/Textures/led_hard.png")
	img_hard2 = load("res://Assets/Textures/led_impossible.png")
	
	img_10 = load("res://Assets/Textures/led_score_10.png")
	img_11 = load("res://Assets/Textures/led_score_11.png")
	img_125 = load("res://Assets/Textures/led_score_125.png")
	img_15 = load("res://Assets/Textures/led_score_15.png")
	img_20 = load("res://Assets/Textures/led_score_20.png")
	
	img_rand = load("res://Assets/Textures/led_random.png")
	img_roll = load("res://Assets/Textures/led_rolling.png")
	img_gold = load("res://Assets/Textures/led_gold.png")
	
	mat_big = get_surface_override_material(0)
	mat_small = get_surface_override_material(1)

func _process(delta):
	if rollin:
		offset1 += Vector2(delta, 0)
		offset2 += Vector2(0, delta * 5.0)
	if shake:
		offset1 = Vector2(randf_range(-0.01,0.01),randf_range(-0.01,0.01))
	mat_big.set_shader_parameter("offset", offset1)
	mat_small.set_shader_parameter("offset", offset2)

func set_diff(diff, gold = false):
	rollin = false
	offset1 = Vector2.ZERO
	offset2 = Vector2.ZERO
	
	if gold:
		mat_big.set_shader_parameter("Text", img_gold)
		mat_small.set_shader_parameter("Text", img_rand)
		return
	
	if diff == "easy":
		mat_big.set_shader_parameter("Text", img_easy)
		mat_small.set_shader_parameter("Text", img_10)
	elif diff == "medium":
		mat_big.set_shader_parameter("Text", img_medium)
		mat_small.set_shader_parameter("Text", img_125)
	elif diff == "hard":
		mat_big.set_shader_parameter("Text", img_hard)
		mat_small.set_shader_parameter("Text", img_15)
	elif diff == "hard2":
		shake = true
		mat_big.set_shader_parameter("Text", img_hard2)
		mat_small.set_shader_parameter("Text", img_20)
		
func set_roll():
	rollin = true
	shake = false
	mat_big.set_shader_parameter("Text", img_roll)
	mat_small.set_shader_parameter("Text", img_rand)
