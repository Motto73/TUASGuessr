@tool
extends Node3D

##[color=red][b]DO NOT CHANGE THIS[/b][/color] - the actual database file.
@export var DataAsset : ItemDataPoints
##Press this if you want to write the current points to the local database.
@export var DoRefresh : bool = false
@export var PreviewText : Label3D

func _ready():
	if Engine.is_editor_hint():
		var editor_selection = EditorInterface.get_selection()
		editor_selection.selection_changed.connect(_on_selection_changed)
		_on_selection_changed()

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

func _on_selection_changed():
	var editor_selection = EditorInterface.get_selection()
	var nod
	for item in editor_selection.get_selected_nodes():
		if item is ShopItem:
			nod = item
			break
	if nod:
		PreviewText.text = "Name: " + (nod as ShopItem).name + "\n"
		PreviewText.text += "Tag: " + (nod as ShopItem).Tag + "\n"
		PreviewText.text += "Price: " + str((nod as ShopItem).Price) + "\n"
		PreviewText.text += "Rarity: " + str((nod as ShopItem).Rarity) + "\n"
		PreviewText.position = nod.position + Vector3(0, 1.25, 0)
