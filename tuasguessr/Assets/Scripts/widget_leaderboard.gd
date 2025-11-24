extends Node2D

class_name Leaderboard

@onready var loading = find_child("Loading", true, false)
@onready var box = find_child("VBoxContainer", true, false)

func _ready() -> void:
	Game.Active.actualGame.load_scoreboard()

#Expected format: dictionary{ "name" : points }
func set_data(dat: Array):
	#Reparent to instanly move the loading thingamabob away, then queue deletion
	loading.reparent(self)
	loading.queue_free()
	for entry in dat:
		var name = entry.get("username", "Unknown")
		var pts = entry.get("points", 0)
		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate() as Label
		tag.text = str(name) + " : " + str(pts)
		box.add_child(tag)
