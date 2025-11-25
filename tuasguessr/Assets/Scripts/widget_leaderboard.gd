extends Node2D

class_name Leaderboard

@onready var loading = find_child("Loading", true, false)
@onready var box = find_child("VBoxContainer", true, false)

func _ready() -> void:
	# Pyydetään tuore data avatessa
	Firebase.check_scoreboard_for_updates()

#Expected format: dictionary{ "name" : points }
func set_data(dat: Array):
	# Poista loading vain ensimmäisellä kerralla
	if loading and is_instance_valid(loading):
		loading.queue_free()
		loading = null  # <-- tärkeä, estää seuraavan kutsun virheen

	# Tyhjennä vanhat tagit
	for child in box.get_children():
		child.queue_free()

	var num = 1
	for entry in dat:
		var name = entry.get("username", "Unknown")
		var pts = entry.get("points", 0)
		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate() as Label

		tag.text = str(num) + ". " + name + " : " + str(pts)
		num += 1

		box.add_child(tag)
	Firebase.check_scoreboard_for_updates()
