# pickup_item.gd
extends Area3D
class_name PickupItem # Le damos un nombre de clase para identificarlo fácilmente

# Aquí arrastrarás tu archivo "cubo_antigravedad.tres" desde el editor
@export var item_resource: ItemData 
@export var amount_to_give: int = 1

func _ready() -> void:
	# Ya no conectamos la señal body_entered. ¡Este código está limpio ahora!
	pass

# El jugador llamará a esta función cuando presione el botón mirándolo
func interact(player: Player) -> void:
	var inventory = player.get_node_or_null("Inventory")
	if inventory:
		# Le decimos al inventario que intente guardar el ítem
		var was_picked_up = inventory.add_targeted_item(item_resource, amount_to_give, player)
		if was_picked_up:
			queue_free() # Borramos el objeto del suelo