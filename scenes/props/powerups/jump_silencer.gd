# jump_silencer.gd
extends Area3D

func _ready() -> void:
	# Conectamos la señal de que algo entró al área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		# Buscamos el nodo de salto por su nombre o tipo
		var jump_node = body.get_node_or_null("JumpMechanic")
		
		if jump_node and jump_node.is_active:
			desactivar_salto(jump_node)
			# Ocultamos el cubo visualmente mientras esperamos
			visible = false 
			# Desactivamos su colisión para que no se active dos veces
			$CollisionShape3D.set_deferred("disabled", true)

func desactivar_salto(node: PlayerMechanic) -> void:
	node.is_active = false
	print("Salto desactivado")
	
	# Esperar 6 segundos
	await get_tree().create_timer(6.0).timeout
	
	node.is_active = true
	print("Salto reactivado")
	queue_free() # Eliminar el objeto del mundo