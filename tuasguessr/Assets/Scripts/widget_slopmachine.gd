extends Control

class_name SlopMachine

var Slots : Slots3D

func _ready():
	Slots = $SubViewportContainer/SubViewport/Slots3D

var sparkle := false
func set_sparkle(val):
	sparkle = val
	$"SubViewportContainer/SubViewport/Sparkle On".emitting = val
