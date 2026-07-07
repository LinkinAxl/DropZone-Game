extends Node2D

# Cargamos la plantilla del objeto que creamos antes
var escena_objeto = preload("res://objeto.tscn")

# Variables del juego
var puntos : int = 0
var vidas : int = 3
var juego_terminado : bool = false
var tiempo_restante : int = 180 # 3 minutos de partida (180 segundos)

# Nodos que usaremos (los crearemos de forma automática por código para los textos)
var texto_ui : Label
var boton_salir_gameover : Button

# --- NUEVO: SISTEMA DE MÚSICA AL AZAR ---
var reproductor_musica : AudioStreamPlayer
# Lista de 5 temazos Hardcore/Breakbeat/Synthwave Cyberpunk de internet
var lista_canciones : Array = [
	"https://raw.githubusercontent.com/thegodotist/arcade-assets/main/music/hardcore_track1.mp3",
	"https://raw.githubusercontent.com/thegodotist/arcade-assets/main/music/hardcore_track2.mp3",
	"https://raw.githubusercontent.com/thegodotist/arcade-assets/main/music/hardcore_track3.mp3",
	"https://raw.githubusercontent.com/thegodotist/arcade-assets/main/music/hardcore_track4.mp3",
	"https://raw.githubusercontent.com/thegodotist/arcade-assets/main/music/hardcore_track5.mp3"
]

func _ready() -> void:
	# Creamos un texto simple en pantalla para ver los puntos y las vidas
	texto_ui = Label.new()
	texto_ui.position = Vector2(30, 20)
	
	# Maquillaje Estilo Arcade/Neón para el texto
	var configuracion_letras = LabelSettings.new()
	configuracion_letras.font_size = 26
	configuracion_letras.font_color = Color(1, 1, 1)
	configuracion_letras.outline_size = 6
	configuracion_letras.outline_color = Color(0, 0, 0)
	texto_ui.label_settings = configuracion_letras
	
	add_child(texto_ui)
	actualizar_interfaz()
	iniciar_reloj_descenso()
	
	# Ajuste inicial del timer de aparición
	$Timer.wait_time = 0.6
	$Timer.timeout.connect(_on_timer_timeout)
	
	# Conectamos al jugador para saber cuándo lo toca un objeto
	$Jugador.area_entered.connect(_on_jugador_area_entered)
	
	# --- INICIALIZAR LA MÚSICA ARCADE ---
	reproductor_musica = AudioStreamPlayer.new()
	add_child(reproductor_musica)
	# Si una canción termina, llamamos a poner otra al azar automáticamente
	reproductor_musica.finished.connect(reproducir_siguiente_cancion)
	reproducir_siguiente_cancion()

func _process(_delta: float) -> void:
	# Si perdiste y presionas la tecla R, el juego se reinicia solo
	if juego_terminado and Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()
		
	# Aceleración de la barra suave
	if not juego_terminado and has_node("Jugador"):
		var velocidad_base_teclado = 500.0
		var extra_por_puntos = sqrt(puntos) * 15.0 
		$Jugador.velocidad = velocidad_base_teclado + extra_por_puntos

# --- NUEVA FUNCIÓN: SELECCIÓN Y REPRODUCCIÓN ALEATORIA ---
func reproducir_siguiente_cancion() -> void:
	if juego_terminado:
		return
		
	# Elegimos un índice al azar entre las 5 canciones de la playlist
	var indice_azar = randi() % lista_canciones.size()
	var url_cancion = lista_canciones[indice_azar]
	
	# Intentamos cargar la canción
	var stream = AudioStreamMP3.new() # Asumimos formato MP3 estándar para internet
	# Nota: Si prefieres descargar tus canciones a la PC, solo cambia los links de la lista de arriba
	# por rutas locales tipo "res://musica/track1.mp3" y usa: reproductor_musica.stream = load(url_cancion)
	
	# Carga segura (Marcador de posición por si usas archivos locales)
	if url_cancion.begins_with("res://"):
		reproductor_musica.stream = load(url_cancion)
	else:
		# Godot 4 puede cargar streams HTTP si el proyecto está configurado o usar archivos en local
		# Para asegurar que tu entrega funcione de inmediato sin lags de internet, puedes arrastrar 5 mp3s a tu proyecto
		# y renombrar la lista_canciones con: ["res://pista1.mp3", "res://pista2.mp3", etc]
		reproductor_musica.stream = load(url_cancion) if ResourceLoader.exists(url_cancion) else null
		
	if reproductor_musica.stream:
		reproductor_musica.play()

func _on_timer_timeout() -> void:
	if juego_terminado:
		return
		
	var nuevo_objeto = escena_objeto.instantiate()
	
	# Lógica de dificultad suave para la velocidad de caída
	var velocidad_base = 280 
	var extra_por_puntos = sqrt(puntos) * 12.0 
	
	if "velocidad" in nuevo_objeto:
		nuevo_objeto.velocidad = velocidad_base + extra_por_puntos
	
	# Spawn en toda la pantalla
	var x_al_azar = randf_range(50, 1100) 
	nuevo_objeto.position = Vector2(x_al_azar, -50)
	
	add_child(nuevo_objeto)
	
	# Ritmo de aparición equilibrado
	var nuevo_tiempo_espera = clamp(0.6 - (puntos * 0.0015), 0.15, 0.6)
	$Timer.wait_time = nuevo_tiempo_espera

func _on_jugador_area_entered(area: Area2D) -> void:
	if juego_terminado or not is_instance_valid(area) or area.is_queued_for_deletion():
		return
		
	if "tipo_objeto" in area:
		var pos_impacto = area.global_position
		
		# --- CASO 0: CUBO VERDE (BUENO) ---
		if area.tipo_objeto == 0:
			puntos += 10
			crear_explosion_particulas(pos_impacto, Color(0.2, 1.0, 0.2)) 
			destellar_jugador(Color(0.4, 1.0, 0.4)) 
			area.queue_free()
			actualizar_interfaz()
			
		# --- CASO 2: CUBO DORADO (ESPECIAL) ---
		elif area.tipo_objeto == 2:
			puntos += 50 
			if vidas < 3:
				vidas += 1 
			crear_explosion_particulas(pos_impacto, Color(1.0, 0.85, 0.0)) 
			destellar_jugador(Color(1.0, 0.9, 0.3)) 
			area.queue_free()
			actualizar_interfaz()
			
		# --- CASO 1: CUBO ROJO (MALO) ---
		elif area.tipo_objeto == 1:
			vidas -= 1
			actualizar_interfaz()
			
			crear_explosion_particulas(pos_impacto, Color(1.0, 0.1, 0.1)) 
			
			if area.has_node("CollisionShape2D"):
				area.get_node("CollisionShape2D").set_deferred("disabled", true)
			
			# Efecto de parpadeo de daño en toda la pantalla
			modulate = Color(1, 0.3, 0.3) 
			await get_tree().create_timer(0.15).timeout
			
			if not juego_terminado:
				modulate = Color(1, 1, 1) 
			
			if is_instance_valid(area):
				area.queue_free()
		
		# Revisamos si perdiste por quedarte sin vidas
		if vidas <= 0:
			finalizar_juego_por_vidas()

func destellar_jugador(color_destello: Color) -> void:
	if has_node("Jugador"):
		$Jugador.modulate = color_destello
		await get_tree().create_timer(0.08).timeout
		if has_node("Jugador"):
			$Jugador.modulate = Color(1, 1, 1)

func crear_explosion_particulas(posicion: Vector2, color_chispas: Color) -> void:
	var particulas = CPUParticles2D.new()
	particulas.global_position = posicion
	particulas.amount = 25 
	particulas.lifetime = 0.35 
	particulas.one_shot = true 
	particulas.explosiveness = 0.9 
	particulas.direction = Vector2(0, -1) 
	particulas.spread = 80.0 
	particulas.gravity = Vector2(0, 400) 
	particulas.initial_velocity_min = 180.0 
	particulas.initial_velocity_max = 300.0
	particulas.color = color_chispas
	particulas.local_coords = false
	
	var curva_escala = Curve.new()
	curva_escala.add_point(Vector2(0, 7)) 
	curva_escala.add_point(Vector2(1, 0)) 
	particulas.scale_amount_curve = curva_escala
	
	add_child(particulas)
	get_tree().create_timer(0.5).timeout.connect(particulas.queue_free)

func actualizar_interfaz() -> void:
	var minutos = tiempo_restante / 60
	var segundos = tiempo_restante % 60
	texto_ui.text = "Puntos: " + str(puntos) + "   |   Vidas: " + str(vidas) + "   |   Tiempo: %d:%02d" % [minutos, segundos]

func iniciar_reloj_descenso() -> void:
	var reloj_timer = Timer.new()
	reloj_timer.wait_time = 1.0 
	reloj_timer.autostart = true
	add_child(reloj_timer)
	reloj_timer.timeout.connect(_on_reloj_timeout)

func _on_reloj_timeout() -> void:
	if juego_terminado:
		return
		
	tiempo_restante -= 1
	actualizar_interfaz()
	
	if tiempo_restante <= 0:
		finalizar_juego_por_tiempo()

func finalizar_juego_por_tiempo() -> void:
	juego_terminado = true
	if reproductor_musica:
		reproductor_musica.stop() # Apagar música al terminar
	texto_ui.text = "¡TIEMPO AGOTADO! | Puntaje Máximo: " + str(puntos) + "\nPresiona 'R' para reiniciar o usa el botón:"
	crear_boton_salir()

func finalizar_juego_por_vidas() -> void:
	juego_terminado = true
	if reproductor_musica:
		reproductor_musica.stop() # Apagar música en Game Over
	modulate = Color(0.6, 0.3, 0.3)
	texto_ui.text = "GAME OVER | Puntos finales: " + str(puntos) + "\nPresiona 'R' para reiniciar o usa el botón:"
	crear_boton_salir()

func crear_boton_salir() -> void:
	boton_salir_gameover = Button.new()
	boton_salir_gameover.text = "Salir al Menú"
	boton_salir_gameover.position = Vector2(30, 120) 
	boton_salir_gameover.custom_minimum_size = Vector2(150, 40)
	boton_salir_gameover.pressed.connect(_on_boton_salir_gameover_pressed)
	add_child(boton_salir_gameover)

func _on_boton_salir_gameover_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_inicio.tscn")
