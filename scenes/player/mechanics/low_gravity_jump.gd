# low_gravity_jump.gd
extends PlayerMechanic

@export var high_jump_force = 12.0
@export var low_gravity_multiplier = 0.4

func physics_update(delta: float) -> void:
	# Modificar la gravedad mientras esta mecánica esté activa
	if not player.is_on_floor():
		# Aplicamos una fuerza hacia arriba constante para simular menos gravedad
		player.velocity += (player.get_gravity() * low_gravity_multiplier * -1) * delta

	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = high_jump_force