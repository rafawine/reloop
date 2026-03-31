# powerup_low_grav.gd
extends Area3D

# Cargamos el script de la nueva mecánica
const LOW_GRAV_SCRIPT = preload("res://scenes/player/mechanics/low_gravity_jump.gd")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		aplicar_poder(body)
		visible = false
		$CollisionShape3D.set_deferred("disabled", true)

func aplicar_poder(player_node: Player) -> void:
	# 1. Crear el nodo de la mecánica
	var new_mechanic = Node.new()
	new_mechanic.set_script(LOW_GRAV_SCRIPT)
	new_mechanic.name = "LowGravMechanic"
	
	# 2. Agregarlo al jugador
	player_node.add_child(new_mechanic)
	player_node.update_mechanics_list()
	print("Poder lunar activado")
	
	# 3. Esperar 6 segundos
	await get_tree().create_timer(6.0).timeout
	
	# 4. Eliminar la mecánica y actualizar la lista
	new_mechanic.queue_free()
	# Esperamos un frame para que se elimine antes de actualizar la lista
	await get_tree().process_frame 
	player_node.update_mechanics_list()
	print("Poder lunar agotado")
	queue_free()