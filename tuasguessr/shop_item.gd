extends Node3D

@export var bobspeed := 1.0
@export var floatspeed := 1.0

var timer = 0.0
@onready var ogpos

func _ready():
	ogpos = position

func _process(delta):
	timer += delta
	position = ogpos + sin(timer * bobspeed) * Vector3(0,1,0) * 0.5
	rotate(Vector3.UP, delta * floatspeed)
