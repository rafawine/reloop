class_name StateSlide
extends MovementState

## Estado de deslizamiento basado en inercia y proyección de vectores normales.

@export_category("Configuración de Deslizamiento")
@export var base_impulse: float = 12.0
@export var friction: float = 2.0
@export var slope_acceleration: float = 15.0
@export var exit_speed_threshold: float = 4.0

# Vector interno que almacena el momentum durante el deslizamiento
var current_slide_momentum: Vector3 = Vector3.ZERO

func enter() -> void:
    # 1. Capturar la inercia al entrar al estado.
    # Desacoplamos la dirección visual de la física: nos deslizamos hacia donde mira el modelo o la cámara.
    var forward_dir: Vector3 = - player.global_transform.basis.z.normalized()
    
    # 2. Conservar el momentum previo o aplicar un impulso mínimo si venía lento
    var current_horizontal_velocity := Vector3(player.velocity.x, 0.0, player.velocity.z)
    var entry_speed: float = current_horizontal_velocity.length()
    
    var slide_speed: float = max(entry_speed, base_impulse)
    
    # Establecer el momentum inicial
    current_slide_momentum = forward_dir * slide_speed

func physics_update(delta: float) -> void:
    # Salida de seguridad: Si caemos por un borde, la State Machine debe cambiar a State_Air
    if not player.is_on_floor():
        return # La transición se maneja en la máquina de estados central

    var floor_normal: Vector3 = player.get_floor_normal()
    
    # 3. Calcular la dirección y fuerza de la pendiente (Fórmula matemática)
    var gravity_dir: Vector3 = Vector3.DOWN
    # Restamos al vector de gravedad su proyección sobre la normal del suelo
    var slope_vector: Vector3 = gravity_dir - (gravity_dir.dot(floor_normal) * floor_normal)
    
    # 4. Modificar el momentum basado en la pendiente
    # Si estamos en un terreno plano, slope_vector será (casi) Vector3.ZERO
    current_slide_momentum += slope_vector * slope_acceleration * delta
    
    # 5. Aplicar fricción continua (Decaimiento exponencial hacia cero)
    current_slide_momentum = current_slide_momentum.lerp(Vector3.ZERO, friction * delta)
    
    # 6. Aplicar la velocidad calculada al CharacterBody3D
    player.velocity.x = current_slide_momentum.x
    player.velocity.z = current_slide_momentum.z
    # Nota: No tocamos player.velocity.y aquí para que la gravedad base (del PlayerController) siga actuando.
    
    # 7. Condición de salida por pérdida de inercia
    var current_speed: float = Vector3(player.velocity.x, 0.0, player.velocity.z).length()
    if current_speed < exit_speed_threshold:
        # En una arquitectura real por eventos, emitimos una señal al cerebro para cambiar de estado
        # event_bus.state_transition_requested.emit(self, "State_Crouch")
        pass

func exit() -> void:
    # Limpieza de variables si es necesario al salir del estado
    current_slide_momentum = Vector3.ZERO