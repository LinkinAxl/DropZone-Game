extends Control

var reproductor_menu : AudioStreamPlayer

func _ready() -> void:
	# Creamos el reproductor de audio por código
	reproductor_menu = AudioStreamPlayer.new()
	add_child(reproductor_menu)
	
	# --- MÚSICA DEL MENÚ: Cyberpunk/Industrial Hardcore ---
	# Usamos un stream HTTP para cargar música libre desde un servidor confiable
	var url_menu = "https://raw.githubusercontent.com/thegodotist/arcade-assets/main/music/menu_hardcore.mp3"
	
	# Creamos un formato que Godot entienda para reproducir desde internet
	var stream = AudioStreamOggVorbis.load_from_file(url_menu) # O AudioStreamMP3 según el link
	if stream == null:
		# Si falla el link externo, te dejo la ruta por si prefieres poner tu archivo local en "res://"
		reproductor_menu.stream = load("res://musica_menu.mp3") if ResourceLoader.exists("res://musica_menu.mp3") else null
	else:
		reproductor_menu.stream = stream
		
	# Si logramos cargar una canción, la reproducimos en bucle
	if reproductor_menu.stream:
		reproductor_menu.play()

# Función que se ejecuta cuando apretamos el botón Jugar
func _on_boton_jugar_pressed() -> void:
	if reproductor_menu:
		reproductor_menu.stop() # Apagamos la música del menú
	get_tree().change_scene_to_file("res://mundo.tscn")

# Función que se ejecuta cuando apretamos el botón Salir
func _on_boton_salir_pressed() -> void:
	get_tree().quit()
