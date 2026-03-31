# player_mechanic.gd
extends Node
class_name PlayerMechanic

# Referencia al jugador para poder modificar su velocidad, animaciones, etc.
var player: CharacterBody3D
var is_active: bool = true

func _ready() -> void:
	# Al agregarse como hijo, automáticamente busca al jugador
	player = get_parent() as CharacterBody3D
	if not player:
		push_warning("Una PlayerMechanic debe ser hija del jugador.")

# Función que el jugador llamará cada frame físico
func physics_update(_delta: float) -> void:
	pass

# Función que el jugador llamará cuando haya un input (teclado/ratón)
func handle_input(_event: InputEvent) -> void:
	pass