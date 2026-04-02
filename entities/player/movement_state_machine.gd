class_name MovementStateMachine
extends Node

## Máquina de estados finita que administra el comportamiento físico del jugador.

@export var initial_state: NodePath

@onready var player: PlayerController = owner

var states: Dictionary = {}
var current_state: MovementState

func _ready() -> void:
    # Registrar todos los estados hijos automáticamente
    for child in get_children():
        if child is MovementState:
            # Usamos StringName (&) para búsquedas de alta velocidad en memoria
            states[StringName(child.name)] = child
            child.player = player
            child.state_machine = self
            print("child: ", child.name)
            
    if initial_state:
        _transition_to(StringName(get_node(initial_state).name))

# Esta función es llamada desde el _physics_process del PlayerController
func process_physics(delta: float) -> void:
    if current_state:
        print("llega aqui")
        current_state.physics_update(delta)

func transition_to(target_state_name: StringName) -> void:
    if not states.has(target_state_name):
        push_error("Estado de movimiento no encontrado: ", target_state_name)
        return
        
    _transition_to(target_state_name)

func _transition_to(target_state_name: StringName) -> void:
    if current_state:
        current_state.exit()
        
    current_state = states[target_state_name]
    current_state.enter()