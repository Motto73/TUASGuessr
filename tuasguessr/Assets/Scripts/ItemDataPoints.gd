@tool
extends Resource

class_name ItemDataPoints

@export var Items : Array[ItemDataPoint]

func refresh(datas):
	Items = []
	for data : ShopItem in datas:
		var d = ItemDataPoint.new()
		d.price = data.Price
		d.rarity = data.Rarity
		d.tag = data.Tag
		Items.append(d)
