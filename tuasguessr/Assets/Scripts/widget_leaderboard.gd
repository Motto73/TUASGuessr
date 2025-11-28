extends Node2D

class_name Leaderboard

@export var menu_leaderboard_path: NodePath
@onready var menu_leaderboard = get_node(menu_leaderboard_path)
@onready var loading = find_child("Loading", true, false)
@onready var box = find_child("VBoxContainer", true, false)

func set_data(dat: Array):
	show_loading()  # varmistus

	# Tyhjennä lista
	for child in box.get_children():
		child.queue_free()

	var num = 1
	for entry in dat:
		var name = entry.get("username", "Unknown")
		var pts = entry.get("points", 0)
		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate() as Label
		tag.text = str(num) + ". " + name + " : " + str(pts)
		box.add_child(tag)
		num += 1

	hide_loading()


func update_list():
	print("DEBUG: Leaderboard UI Update called")
	Game.Active.actualGame.update_lb_ui()

func show_loading():
	if loading:
		loading.visible = true
		
func hide_loading():
	if loading:
		loading.visible = false
