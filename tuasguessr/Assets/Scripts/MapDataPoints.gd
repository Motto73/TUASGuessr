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
		d.position = data.global_position - Vector3(0, data.global_position.y,0)
		d.floor = round(data.global_position.y / 2.0) + 1
		DataPoints.append(d)
