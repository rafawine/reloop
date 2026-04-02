class_name StateIdle
extends MovementState

@export var friction: float = 10.0

func physics_update(delta: float) -> void:
    if not player.is_on_floor():
        state_machine.transition_to(&"State_Air")
        return
        
    if player.is_jumping:
        player.velocity.y = player.jump_velocity
        state_machine.transition_to(&"State_Air")
        return
        
    if player.current_input_dir != Vector2.ZERO:
        state_machine.transition_to(&"State_Run")
        return
        
    # Aplicar fricción para detenerse suavemente
    player.velocity.x = move_toward(player.velocity.x, 0.0, friction * delta)
    player.velocity.z = move_toward(player.velocity.z, 0.0, friction * delta)