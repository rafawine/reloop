extends Node

## Autoload: EventBus
## Centraliza las señales globales para evitar acoplamiento fuerte.

# Sistema de Combate y Jugador
signal player_health_changed(current_health: float, max_health: float, current_shield: float)
signal player_ammo_updated(current_ammo: int, reserve_ammo: int)
signal killfeed_event_generated(killer_name: String, victim_name: String, weapon_used: String)

# Sistema de Mundo
signal loot_dropped(item_data: Resource, global_position: Vector3)