class_name PlayerController
extends CharacterBody3D

## Controlador base diseñado para arquitecturas Autoridad de Servidor.
## Utiliza una Máquina de Estados (no incluida aquí para brevedad) para delegar la lógica.

@export var speed_walk: float = 5.0
@export var speed_sprint: float = 8.0
@export var jump_velocity: float = 4.5
@export var gravity_multiplier: float = 1.5

@onready var visual_root: Node3D = $VisualRoot
@onready var state_machine: Node = $MovementStateMachine
#@onready var state_machine = $MovementStateMachine # Es temporal, arreglar para la linea comentada de arriba

# Variables de estado de red
var current_input_dir: Vector2 = Vector2.ZERO
var is_jumping: bool = false
var is_sliding: bool = false

# Se obtiene la gravedad global del proyecto
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# 1. Recolectar Input (En red, esto se envía al servidor antes de procesar)
	_gather_inputs()
	
	# 2. Aplicar Gravedad
	if not is_on_floor():
		velocity.y -= (gravity * gravity_multiplier) * delta
		
	# 3. La Máquina de Estados modifica la variable 'velocity' 
	# basándose en 'current_input_dir' y el estado actual (Deslizamiento, Aire, etc.)
	state_machine.process_physics(delta)
	#if state_machine.has_method("process_physics"): # Es temporal, arreglar para la linea comentada de arriba
		#print("llega aqui")
		#state_machine.process_physics(delta)
	
	# 4. Aplicar movimiento (Nativo de Godot 4.x, ya no requiere argumentos)
	move_and_slide()

func _process(delta: float) -> void:
	# Interpolación visual para pantallas de alta tasa de refresco (High Refresh Rate)
	# Evita el 'stuttering' en juegos multijugador.
	visual_root.global_transform = visual_root.global_transform.interpolate_with(global_transform, delta * 15.0)

func _gather_inputs() -> void:
	# En un entorno multijugador real, esta función solo se ejecuta si el nodo es controlado por el peer local.
	current_input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	is_jumping = Input.is_action_just_pressed("jump")
	is_sliding = Input.is_action_just_pressed("slide")
