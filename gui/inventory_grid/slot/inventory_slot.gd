extends Control

const PANNEL = preload("res://gui/inventory_grid/slot/slot_panel.tres")
const PANNEL_HIGHLIGHT = preload("res://gui/inventory_grid/slot/slot_panel_highlight.tres")

var index: int = -1 setget set_index

func set_equipped(eq: bool) -> void:
	if eq:
		$PanelContainer.add_stylebox_override("panel", PANNEL_HIGHLIGHT)
	else:
		$PanelContainer.add_stylebox_override("panel", PANNEL)

func set_texture(tex: Texture) -> void:
	$PanelContainer/TextureRect.texture = tex
	
func set_index(i: int) -> void:
	index = i
	$Label.text = str(i)
