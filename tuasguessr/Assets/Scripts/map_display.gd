extends Node2D

class_name MapDisplay

@onready var map3d : Map3D = find_child("3dMap", true, false)
@onready var button : Button = find_child("Button", true, false)

var currentGuess : Vector3
var actualPoint : MapDataPoint

var state = "loading"

func reset():
	close()

func _ready():
	close()

func _on_button_down():
	Sounds.play_button_normal()
	state = "accepted"
	close()
	if Game.Active.actualGame.eval_points():
		map3d.reveal()

func open(data):
	actualPoint = data
	state = "input"
	map3d.CanMove = true

func close():
	state = "waiting"
	button.disabled = true
	floor_hint(true)

func update_guess(pos):
	floor_hint(false)
	currentGuess = pos
	state = "ready"
	button.disabled = false
	#The hot, cold thingamabob
	if Game.Active.actualGame.inventorytags.has("thermo"):
		var dist = actualPoint.position.distance_to(pos) * Game.Active.actualGame.GodotToMeters
		var text = "Freezing..."
		if dist < 10:
			text = "Hot!!!"
		elif dist < 25:
			text = "Warm!"
		elif dist < 50:
			text = "Cold."
		elif dist < 75:
			text = "Very cold.."
		var pop = load("res://Resource Scenes/pointspopupsmall.tscn").instantiate()
		pop.position = get_viewport().get_mouse_position()
		pop.text = text
		Game.Active.actualGame.topcanvas.add_child(pop)

func lock():
	state = "locked"
	button.disabled = true
	map3d.lock()


func buttonpressed(num):
	map3d.show_floor(num)
	Game.Active.actualGame.currentFloor = num


#Yes, this is probably very dumb.
func _on_texture_button_button_down():
	buttonpressed(0)
func _on_texture_button_2_button_down():
	buttonpressed(1)
func _on_texture_button_3_button_down():
	buttonpressed(2)
func _on_texture_button_4_button_down():
	buttonpressed(3)
	
func floor_hint(hide):
	if not Game.Active.actualGame:
		return
	if not Game.Active.actualGame.inventorytags.has("level"):
		return
	var buttons := [$CanvasLayer/Control/Floor0,$CanvasLayer/Control/Floor1,$CanvasLayer/Control/Floor2,$CanvasLayer/Control/Floor3]
	if hide:
		var c = Color(1.0, 1.0, 1.0, 1.0)
		for b in buttons:
			b.modulate = c
	else:
		var guess = map3d.currentfloor
		var real = actualPoint.floor
		var c = Color(0.72, 0.72, 0.72, 1.0)
		for  b in buttons:
			b.modulate = c
		buttons[real].modulate = Color(1.0, 1.0, 1.0, 1.0)
