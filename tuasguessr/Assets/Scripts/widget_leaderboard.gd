extends Node2D

class_name Leaderboard

@export var menu_leaderboard_path: NodePath
@onready var menu_leaderboard = get_node(menu_leaderboard_path)
@onready var loading = find_child("Loading", true, false)
@onready var box = find_child("VBoxContainer", true, false)

func _ready():
	loading.show()
	hide_scoretags()

func set_data(dat: Array):
	# 1) Näytä loading
	if loading:
		loading.visible = true

	# --- ODOTA 1 FRAME → UI piirtyy ---
	await get_tree().process_frame

	# 2) Poista vain scoretagit, EI loadingia
	for child in box.get_children():
		if child != loading:
			child.queue_free()
	
	hide_loading()
	
	# 3) Luo uudet piste-tagit
	var num = 1
	for entry in dat:
		await get_tree().create_timer(0.1).timeout
		
		var name = entry.get("username", "Unknown")
		var pts  = entry.get("points", 0)

		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate()
		tag.text = str(num) + ". " + name + " : " + str(pts)
		num += 1

		box.add_child(tag)


func update_list():
	print("DEBUG: Leaderboard UI Update called")
	Game.Active.actualGame.update_lb_ui()

func hide_loading():
	# 4) Piilota loading
	if loading:
		loading.visible = false
		
func show_loading():
	if loading:
		loading.visible = true
		
func hide_scoretags():
	for child in box.get_children():
		if child != loading:
			child.visible = false
