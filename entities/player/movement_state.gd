class_name MovementState
extends Node

## Clase base para todos los estados de movimiento del jugador.

# El cerebro inyectará esta referencia al inicializarse
var player: PlayerController
var state_machine: MovementStateMachine

func enter() -> void:
    pass

func exit() -> void:
    pass

func physics_update(_delta: float) -> void:
    pass