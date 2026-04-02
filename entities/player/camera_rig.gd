class_name CameraRig
extends Node3D

## Controlador de Cámara TPS (Third Person Shooter)
## Maneja rotación por ratón, cambio de hombro, ADS y prevención de colisiones.

@export_category("Sensibilidad y Control")
@export var mouse_sensitivity: float = 0.002
@export var vertical_angle_limit: Vector2 = Vector2(-70.0, 70.0) # Grados min/max

@export_category("Configuración de Apuntado (ADS)")
@export var normal_fov: float = 90.0
@export var aim_fov: float = 65.0
@export var normal_spring_length: float = 3.0
@export var aim_spring_length: float = 1.2
@export var shoulder_offset_x: float = 0.8
@export var transition_speed: float = 15.0 # Velocidad de interpolación

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot
@onready var spring_arm: SpringArm3D = $HorizontalPivot/VerticalPivot/SpringArm3D
@onready var camera: Camera3D = $HorizontalPivot/VerticalPivot/SpringArm3D/Camera3D

# Referencia al CharacterBody3D padre para excluirlo de colisiones
@onready var player: CharacterBody3D = get_parent()

var is_aiming: bool = false
var is_right_shoulder: bool = true

func _ready() -> void:
    # Capturar el cursor en la ventana del juego
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    
    # Prevenir que la cámara colisione con la cápsula del propio jugador
    if player and player is CollisionObject3D:
        spring_arm.add_excluded_object(player.get_rid())

func _unhandled_input(event: InputEvent) -> void:
    # Procesar movimiento del ratón solo si el cursor está capturado
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _handle_camera_rotation(event)

func _process(delta: float) -> void:
    _handle_input_states()
    _interpolate_camera_states(delta)

func _handle_camera_rotation(event: InputEventMouseMotion) -> void:
    # Rotación Horizontal (Eje Y)
    horizontal_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
    
    # Rotación Vertical (Eje X)
    vertical_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
    
    # Clampear (limitar) la rotación vertical para no dar volteretas
    var current_rot_x: float = vertical_pivot.rotation.x
    var min_rad: float = deg_to_rad(vertical_angle_limit.x)
    var max_rad: float = deg_to_rad(vertical_angle_limit.y)
    
    vertical_pivot.rotation.x = clamp(current_rot_x, min_rad, max_rad)

func _handle_input_states() -> void:
    is_aiming = Input.is_action_pressed("aim")
    
    if Input.is_action_just_pressed("swap_shoulder"):
        is_right_shoulder = !is_right_shoulder

func _interpolate_camera_states(delta: float) -> void:
    # 1. Transición de FOV (Zoom visual al apuntar)
    var target_fov: float = aim_fov if is_aiming else normal_fov
    camera.fov = lerp(camera.fov, target_fov, transition_speed * delta)
    
    # 2. Transición de Longitud (Acercar la cámara al hombro)
    var target_length: float = aim_spring_length if is_aiming else normal_spring_length
    spring_arm.spring_length = lerp(spring_arm.spring_length, target_length, transition_speed * delta)
    
    # 3. Transición de Cambio de Hombro (Desplazamiento en X)
    var target_offset_x: float = shoulder_offset_x if is_right_shoulder else -shoulder_offset_x
    spring_arm.position.x = lerp(spring_arm.position.x, target_offset_x, transition_speed * delta)