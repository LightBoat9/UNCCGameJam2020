extends Control

func _init():
	visible = true

func get_logger() -> Control:
	return $HBoxContainer/VBox/Log as Control
	
func get_player_inventory() -> Control:
	return $HBoxContainer/RightPanel/VBoxContainer/PlayerInventory as Control
	
func get_ground_inventory() -> Control:
	return $HBoxContainer/RightPanel/VBoxContainer/GroundInventory as Control
	
func update_hp_bar(hp, max_hp) -> void:
	$HBoxContainer/RightPanel/VBoxContainer/HP/TextureProgress.max_value = max_hp
	$HBoxContainer/RightPanel/VBoxContainer/HP/TextureProgress.value = hp
	$HBoxContainer/RightPanel/VBoxContainer/HP/Amount.text = "%d/%d" % [hp, max_hp]
	
func update_hunger_bar(hunger, max_hunger) -> void:
	$HBoxContainer/RightPanel/VBoxContainer/Hunger/TextureProgress.max_value = max_hunger
	$HBoxContainer/RightPanel/VBoxContainer/Hunger/TextureProgress.value = hunger
	$HBoxContainer/RightPanel/VBoxContainer/Hunger/Amount.text = "%d/%d" % [hunger, max_hunger]
	
func update_mutation_bar(mu, max_mu) -> void:
	$HBoxContainer/RightPanel/VBoxContainer/MU/TextureProgress.max_value = max_mu
	$HBoxContainer/RightPanel/VBoxContainer/MU/TextureProgress.value = mu
	$HBoxContainer/RightPanel/VBoxContainer/MU/Amount.text = "%d/%d" % [mu, max_mu]
	
func from_character(ch: Node) -> void:
	get_ground_inventory().from_position(ch.grid_position)
	get_player_inventory().from_character(ch)
	update_hp_bar(ch.hp, ch.max_hp)
	update_hunger_bar(ch.hunger, ch.max_hunger)
	update_mutation_bar(ch.mutation, ch.max_mutation)
