extends PlayerMechanic

func _ready() -> void:
    super._ready()
    var is_aiming = get_meta("is_aiming")

    if is_aiming:
        print("¡PUM! Tiro de SCAR perfecto al centro (Sin retroceso).")
    else:
        print("¡PUM! Tiro de SCAR de cadera (Con dispersión).")

    # Como es una bala instantánea, se destruye en el mismo frame que nace
    queue_free()