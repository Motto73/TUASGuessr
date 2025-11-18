@tool
extends Node3D

##[color=red][b]DO NOT CHANGE THIS[/b][/color] - the actual database file.
@export var DataAsset : ItemDataPoints
##Press this if you want to write the current points to the local database.
@export var DoRefresh : bool = false

func _process(delta):
	if DoRefresh:
		DoRefresh = false
		refresh()

func refresh():
	print("Attempting to save item data...")
	var children : Array = []
	for c : Node in find_children("", "ShopItem", true, false):
		if c is ShopItem:
			children.append(c)
	DataAsset.refresh(children)
	ResourceSaver.save(DataAsset,DataAsset.resource_path)
	print("Saved data for ", len(children), " items!")
