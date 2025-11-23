extends Node2D

class_name Leaderboard

@onready var loading = find_child("Loading", true, false)
@onready var box = find_child("VBoxContainer", true, false)

#Expected format: dictionary{ "name" : points }
func set_data(dat: Dictionary):
	#Reparent to instanly move the loading thingamabob away, then queue deletion
	loading.reparent(self)
	loading.queue_free()
	#TODO - I still don't know what format the data is in, so I use this dummy for now
	dat = {"name":"yo", "points":5 }
	print(dat)
	for data in dat:
		var name = data[0]
		var pts = data[1]
		var tag = load("res://Resource Scenes/scoretag.tscn").instantiate() as Label
		tag.text = str(name) + " : " + str(pts)
		box.add_child(tag)
