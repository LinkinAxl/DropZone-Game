extends Area2D

var velocidad : float = 250.0

# Cambiamos "es_bueno" por un sistema de tipos: 
# 0 = Bueno (Verde), 1 = Malo (Rojo), 2 = Especial Dorado
var tipo_objeto : int = 0

func _ready() -> void:
	# Respetamos la velocidad base que inyecta el mundo con una variación al azar
	velocidad = velocidad * randf_range(0.8, 1.3)
	
	# --- LÓGICA DE SELECCIÓN DE TIPO ---
	var suerte = randf()
	
	if suerte < 0.10:
		# 10% de probabilidad de ser un Cubo Dorado Especial
		tipo_objeto = 2
		$ColorRect.color = Color(1.0, 0.84, 0.0) # Color Oro Brillante
		velocidad *= 0.8 # Cae un pelito más lento para darle oportunidad al jugador de atraparlo
	elif suerte < 0.55:
		# 45% de probabilidad de ser Bueno (Verde)
		tipo_objeto = 0
		$ColorRect.color = Color.GREEN
	else:
		# 45% de probabilidad de ser Malo (Rojo)
		tipo_objeto = 1
		$ColorRect.color = Color.RED

func _process(delta: float) -> void:
	# Cae constantemente hacia abajo
	position.y += velocidad * delta
	
	# Si se pasa del fondo de la pantalla, se borra solo para no dar lag
	if position.y > 700:
		queue_free()
