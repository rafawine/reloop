# inventory.gd
extends Node
class_name Inventory

const MAX_SLOTS = 5
# Arreglo de diccionarios para representar los slots. 
# Cada slot tendrá un "item" (ItemData) y una "amount" (cantidad).
var slots: Array[Dictionary] = []
var active_slot_index: int = 0 # Recuerda qué slot tenemos en la mano

func _ready() -> void:
	# Inicializamos los 5 slots vacíos
	for i in range(MAX_SLOTS):
		slots.append({"item": null, "amount": 0})

	# Seleccionamos el primer slot por defecto al inicio
	select_slot(0)

# Función para recoger un ítem del suelo
func add_item(item_data: ItemData, amount: int = 1) -> bool:
	# 1. Primero buscamos si ya tenemos este ítem y hay espacio en el stack
	for slot in slots:
		if slot["item"] == item_data and slot["amount"] < item_data.max_stack:
			var space_left = item_data.max_stack - slot["amount"]
			if amount <= space_left:
				slot["amount"] += amount
				return true # Se guardó todo con éxito
			else:
				slot["amount"] += space_left
				amount -= space_left # Guardamos una parte y seguimos buscando dónde meter el resto

	# 2. Si no había stack o se llenó, buscamos un slot completamente vacío
	for slot in slots:
		if slot["item"] == null:
			slot["item"] = item_data
			slot["amount"] = amount
			return true

	print("¡Inventario lleno!")
	return false

# NUEVA FUNCIÓN: Solo selecciona, no consume.
func select_slot(index: int) -> void:
	if index < 0 or index >= MAX_SLOTS: return
	
	active_slot_index = index
	var slot = slots[active_slot_index]
	
	if slot["item"] != null:
		print("Equipado en mano: ", slot["item"].name, " (Cantidad: ", slot["amount"], ")")
	else:
		print("Slot ", index + 1, " equipado (Manos vacías)")

# NUEVA FUNCIÓN DE RECOLECCIÓN
func add_targeted_item(new_item: ItemData, amount: int, player: Player) -> bool:
	var active_slot = slots[active_slot_index]
	
	# 1. ¿Podemos stackear (apilar) en el slot seleccionado?
	if active_slot["item"] == new_item and active_slot["amount"] < new_item.max_stack:
		# (Para simplificar, asumimos que entra todo el amount por ahora)
		active_slot["amount"] += amount
		print("Apilado en el slot activo.")
		return true

	# 2. ¿El slot seleccionado está completamente vacío?
	if active_slot["item"] == null:
		active_slot["item"] = new_item
		active_slot["amount"] = amount
		print("Guardado en el slot activo (estaba vacío).")
		return true
		
	# 3. El slot activo está ocupado por otra cosa. Buscamos CUALQUIER slot vacío.
	for i in range(MAX_SLOTS):
		if slots[i]["item"] == null:
			slots[i]["item"] = new_item
			slots[i]["amount"] = amount
			print("Guardado en el slot vacío número: ", i + 1)
			return true
			
	# 4. Inventario lleno. Soltamos lo que tenemos en la mano y recogemos lo nuevo.
	print("Inventario lleno. Intercambiando ítem activo...")
	drop_item(active_slot_index, player)
	
	active_slot["item"] = new_item
	active_slot["amount"] = amount
	return true

# NUEVA LÓGICA DE SOLTAR ÍTEMS
func drop_item(index: int, player: Player) -> void:
	var slot = slots[index]
	
	# Verificamos que tenga ítem y que la ruta de texto no esté vacía
	if slot["item"] == null or slot["item"].drop_scene_path == "": return
	
	# 1. Cargamos la escena desde la ruta de texto en el disco duro
	var packed_scene = load(slot["item"].drop_scene_path) as PackedScene
	
	# 2. Instanciamos la escena cargada
	var dropped_item = packed_scene.instantiate()
	
	# Le inyectamos sus datos para que funcione como recolectable
	if dropped_item is PickupItem:
		dropped_item.item_resource = slot["item"]
		dropped_item.amount_to_give = slot["amount"]
	
	var current_scene = player.get_tree().current_scene
	current_scene.add_child(dropped_item)
	
	var drop_position = player.global_position + (-player.transform.basis.z * 1.5)
	drop_position.y += 0.5 
	dropped_item.global_position = drop_position
	
	slot["item"] = null
	slot["amount"] = 0

# NUEVA LÓGICA DE USO (Diferencia armas de consumibles)
func execute_active_item(player: Player, is_aiming: bool) -> void:
	var slot = slots[active_slot_index]
	if slot["item"] == null: return
	
	if slot["item"].mechanic_script != null:
		var new_mechanic = slot["item"].mechanic_script.new() 
		new_mechanic.name = slot["item"].name + "Mechanic"
		
		# Inyectamos una variable temporal a la mecánica para que sepa si estamos apuntando
		new_mechanic.set_meta("is_aiming", is_aiming) 
		
		player.add_child(new_mechanic)
		player.update_mechanics_list()
		
		# Solo reducimos el inventario si es un cubo/granada
		if slot["item"].is_consumable:
			slot["amount"] -= 1
			if slot["amount"] <= 0:
				slot["item"] = null
