extends Node2D

class_name Leaderboard

@onready var loading = find_child("Loading", true, false)

func set_data(dat: Array):
	#Reparent to instanly move it away, then queue deletion
	loading.reparent(self)
	loading.queue_free()
	print("Leaderboard data length: ", len(dat))
	for data in dat:
		print(str(data))
