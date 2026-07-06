extends Area2D

@export var velocidad : float = 400.0

func _process(delta: float) -> void:
	var direccion : float = 0.0
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		direccion -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		direccion += 1.0
		
	position.x += direccion * velocidad * delta
	
	# Evitamos que el jugador se salga de los bordes de la pantalla
	position.x = clamp(position.x, 0, 1152 - 120)
