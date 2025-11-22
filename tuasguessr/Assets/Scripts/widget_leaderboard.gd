extends Node2D

class_name Leaderboard

@onready var loading = find_child("Loading", true, false)

#Expected format: dictionary{ "name" : points }
func set_data(dat: Array):
	#Reparent to instanly move the loading thingamabob away, then queue deletion
	loading.reparent(self)
	loading.queue_free()
	for data in dat:
		var name = data[0]
		var pts = data[1]
		#TODO - add a label with name and points to vbox, clip vbox children
