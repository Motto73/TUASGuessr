@tool
extends Node3D

##[color=red][b]DO NOT CHANGE THIS[/b][/color] - the actual database file.
@export var DataAsset : MapDataPoints
##Press this if you want to write the current points to the local database.
@export var DoRefresh : bool = false

func _process(delta):
	if DoRefresh:
		DoRefresh = false
		refresh()

func refresh():
	print("Attempting to save map data...")
	var children : Array = []
	for c : Node in get_children():
		if c is MapMarker:
			children.append(c)
	DataAsset.refresh(children)
	ResourceSaver.save(DataAsset,DataAsset.resource_path)
	print("Saved data for ", len(children), " markers!")
