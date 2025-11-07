extends Node2D

class_name  ShitUI

@onready var timer := $ColorRect2/Timer
@onready var points := $ColorRect3/Points

func set_points(amount):
	points.text = str(amount)

func set_time(s):
	var min = int(s) / 60
	var sec = int(s) % 60
	var hun = int((s - floor(s)) * 100)
	timer.text = "%d:%02d:%02d" % [min, sec, hun]
