extends Area2D

@export var velocidad : float = 250.0
var es_bueno : bool = true

func _ready() -> void:
	# Hace que cada objeto tenga una velocidad al azar entre 200 y 500
	velocidad = randf_range(200.0, 500.0)
	# Elige al azar si es un premio (bueno) o un peligro (malo)
	es_bueno = randf() > 0.5
	
	# Cambia el color según lo que sea
	if es_bueno:
		$ColorRect.color = Color.GREEN # Verde = Bueno
	else:
		$ColorRect.color = Color.RED   # Rojo = Malo

func _process(delta: float) -> void:
	# Cae constantemente hacia abajo
	position.y += velocidad * delta
	
	# Si se pasa del fondo de la pantalla, se borra solo para no dar lag
	if position.y > 700:
		queue_free()
