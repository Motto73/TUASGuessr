extends Label

@export var lifetime := 1.0
@export var curve : Curve
@export var alphacurve : Curve

var life

func _ready():
	life = lifetime

func _process(delta):
	var up = curve.sample(life/lifetime)
	position += Vector2(0,-up)
	modulate.a = alphacurve.sample(life/lifetime)
	life -= delta
	if life < 0:
		queue_free()
