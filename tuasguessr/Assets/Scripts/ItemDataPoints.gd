@tool
extends Resource

class_name ItemDataPoints

@export var Items : Array[ItemDataPoint]

func refresh(datas):
	Items = []
	for data : ShopItem in datas:
		#Experimental
		var scene_path = "%s/%s.tscn" % ["res://Items/", data.name]
		var packed = PackedScene.new()
		var inst = data.duplicate(31)
		inst.position = Vector3.ZERO
		print("ITEM: ", data.name, " | OG: ", data.get_child_count(true), " | NEW: ", inst.get_child_count(true))
		#As it happens, godot is kinda ass when you dig too deep.
		for i in inst.get_children(true):
			i.owner = inst
		packed.pack(inst)
		ResourceSaver.save(packed, scene_path)
		
		var d = ItemDataPoint.new()
		d.name = data.name
		d.desc = data.Description
		d.price = data.Price
		d.rarity = data.Rarity
		d.tag = data.Tag
		d.scene = packed
		Items.append(d)
