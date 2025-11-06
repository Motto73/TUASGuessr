@tool
extends Resource

class_name MapDataPoints

@export var DataPoints : Array

func refresh(datas):
	DataPoints = []
	for data : MapMarker in datas:
		var d := MapDataPoint.new()
		d.name = data.ImageName
		d.imgresource = data.Picture.resource_path
		d.difficulty = data.Difficulty
		d.position = data.global_position
		DataPoints.append(d)
