extends Node2D

# Cargamos la plantilla del objeto que creamos antes
var escena_objeto = preload("res://objeto.tscn")

# Variables del juego
var puntos : int = 0
var vidas : int = 3
var juego_terminado : bool = false

# Nodos que usaremos (los crearemos de forma automática por código para los textos)
var texto_ui : Label

func _ready() -> void:
	# Creamos un texto simple en pantalla para ver los puntos y las vidas
	texto_ui = Label.new()
	texto_ui.position = Vector2(20, 20)
	texto_ui.add_theme_font_size_override("font_size", 24)
	add_child(texto_ui)
	actualizar_interfaz()
	
	# Conectamos el Timer para que llame a la función de crear objetos
	$Timer.timeout.connect(_on_timer_timeout)
	
	# Conectamos al jugador para saber cuándo lo toca un objeto
	$Jugador.area_entered.connect(_on_jugador_area_entered)

func _process(_delta: float) -> void:
	# Si perdiste y presionas la tecla R, el juego se reinicia solo
	if juego_terminado and Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()

func _on_timer_timeout() -> void:
	if juego_terminado:
		return
		
	# Creamos una copia del objeto en el cielo
	var nuevo_objeto = escena_objeto.instantiate()
	
	# Le damos una posición X al azar entre los bordes de la pantalla
	var x_al_azar = randf_range(50, 1100)
	nuevo_objeto.position = Vector2(x_al_azar, -50)
	
	# Lo metemos al mapa
	add_child(nuevo_objeto)

func _on_jugador_area_entered(area: Area2D) -> void:
	if juego_terminado:
		return
		
	# Si lo que tocó al jugador tiene la variable "es_bueno"
	if "es_bueno" in area:
		if area.es_bueno:
			puntos += 10 # Suma puntos si es verde
		else:
			vidas -= 1   # Resta vida si es rojo
			
		area.queue_free() # Destruye el objeto inmediatamente al tocarlo
		actualizar_interfaz()
		
		# Revisamos si perdiste
		if vidas <= 0:
			finalizar_juego()

func actualizar_interfaz() -> void:
	texto_ui.text = "Puntos: " + str(puntos) + "   |   Vidas: " + str(vidas)

func finalizar_juego() -> void:
	juego_terminado = true
	texto_ui.text = "GAME OVER | Puntos finales: " + str(puntos) + "\nPresiona 'R' para reiniciar"
