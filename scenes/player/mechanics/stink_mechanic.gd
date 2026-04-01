extends PlayerMechanic

func _ready() -> void:
    super._ready()
    # Leemos si lo lanzamos apuntando o no
    var was_aiming = get_meta("is_aiming")
    if was_aiming:
        print("Lanzamiento preciso: Nube tóxica a lo lejos.")
    else:
        print("Lanzamiento rápido: Nube tóxica a tus pies.")

    # Se autodestruye en 5 segundos
    get_tree().create_timer(5.0).timeout.connect(queue_free)