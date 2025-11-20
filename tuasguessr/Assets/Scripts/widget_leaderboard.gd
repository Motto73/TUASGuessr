extends Node2D

class_name Leaderboard

@onready var loading = find_child("Loading", true, false)

func set_data(dat: Array):
	#Reparent to instanly move it away, the queue deletion
	loading.reparent(self)
	loading.queue_free()
	print("set_data for leaderboard not implemented!")
