extends Node3D

class_name  ShopItem

@export_category("======Item settings======")
@export var Tag := "None"
@export var Price := 20.0
@export var Rarity := 1.0
@export var Res : Mesh

@export_category("======Visibility settings======")
@export var bobspeed := 1.0
@export var floatspeed := 1.0

var timer = 0.0
@onready var ogpos

func _ready():
	ogpos = position

func _process(delta):
	timer += delta
	position = ogpos + sin(timer * bobspeed * 2.0) * Vector3(0,1,0) * 0.25
	rotate(Vector3.UP, delta * floatspeed)
