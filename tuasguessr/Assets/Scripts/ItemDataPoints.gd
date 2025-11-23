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
		var inst = data.duplicate()
		packed.pack(inst)
		ResourceSaver.save(packed, scene_path)
		
		var d = ItemDataPoint.new()
		d.name = data.name
		d.price = data.Price
		d.rarity = data.Rarity
		d.tag = data.Tag
		d.scene = packed
		Items.append(d)
