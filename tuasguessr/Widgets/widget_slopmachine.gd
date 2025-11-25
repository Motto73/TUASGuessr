extends Control

class_name SlopMachine

var Slots : Slots3D

func _ready():
	Slots = $SubViewportContainer/SubViewport/Slots3D
