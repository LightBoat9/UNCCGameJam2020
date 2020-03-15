extends Weapon

func _init().():
	object_name = "bat"
	
func get_profile() -> Texture:
	return $Sprite.texture
