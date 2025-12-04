extends Node2D

@export var time := 5.0
var timer := 0.0
var show := false

func _ready():
	visible = false


func _process(delta):
	if show:
		return
	timer += delta
	if timer >= time:
		visible = true
		show = true
