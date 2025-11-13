extends Node2D

class_name  ShitUI

@onready var timer := find_child("Timer", true, false)
@onready var points := find_child("Points", true, false)

func set_points(amount):
	points.text = str(amount)

func set_time(s):
	#If time is positive, show time
	if s > 0:
		var min = int(s) / 60
		var sec = int(s) % 60
		var hun = int((s - floor(s)) * 100)
		timer.text = "%d:%02d:%02d" % [min, sec, hun]
	#Else show game over
	else:
		timer.text = "Game Over"
