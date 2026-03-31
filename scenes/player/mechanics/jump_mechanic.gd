# jump_mechanic.gd
extends PlayerMechanic

@export var jump_velocity = 4.8
@export var sprint_speed_ref = 8.0 # Referencia para el empuje del salto largo

var can_mantle = false

func physics_update(_delta: float) -> void:
	if player.is_on_floor():
		can_mantle = true
		
	if Input.is_action_just_pressed("jump"):
		if player.is_on_floor():
			if is_near_edge():
				# Salto Largo
				player.velocity.y = jump_velocity
				player.velocity += -player.transform.basis.z * (sprint_speed_ref * 0.5)
			else:
				# Salto Normal
				player.velocity.y = jump_velocity
				
		elif player.is_on_wall() and can_mantle:
			# Escalado / Doble salto en pared
			player.velocity.y = jump_velocity * 1.2
			can_mantle = false

func is_near_edge() -> bool:
	var space_state = player.get_world_3d().direct_space_state
	var origin = player.global_position + (-player.transform.basis.z * 0.6)
	var end = origin + Vector3(0, -2, 0)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	
	return result.is_empty() and player.is_on_floor()