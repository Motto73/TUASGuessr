extends Node

func _init() -> void:
	if OS.has_feature("web"):
		var packs := [
			"res://dlc.pck",
			"res://game_images.pck"
		]
		

		for p in packs:
			var ok := ProjectSettings.load_resource_pack(p)
			if not ok:
				push_error("PCK ei latautunut: %s" % p)
			else:
				# Debugia varten
				print("Loaded pack: ", p)
