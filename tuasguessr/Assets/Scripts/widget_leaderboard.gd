extends Node2D

class_name Leaderboard

@export var menu_leaderboard_path: NodePath
@onready var menu_leaderboard = get_node(menu_leaderboard_path)
@onready var loading = find_child("Loading", true, false)
@onready var box = find_child("VBoxContainer", true, false)

func _ready():
	pass

#Expected format: dictionary{ "name" : points }
func set_data(dat: Array):
	# Poista loading vain ensimmäisellä kerralla
	if loading and is_instance_valid(loading):
		loading.queue_free()
		loading = null  # <-- tärkeä, estää seuraavan kutsun virheen
		await get_tree().create_timer(0.25).timeout
	# Tyhjennä vanhat tagit
	for child in box.get_children():
		child.queue_free()
	# 3. Luo UI rivit järjestyksessä
	var rank := 1
	for entry in dat:
		await get_tree().create_timer(0.1).timeout
		var name = entry.get("username", "Unknown")
		var pts = entry.get("score", 0)
		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate() as Label

		tag.text = str(rank) + ". " + name + " : " + str(pts)
		
		box.add_child(tag)
		rank += 1

func update_list():
	pass
