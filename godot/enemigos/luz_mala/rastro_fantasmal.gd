extends Area2D

var tiempo_total: float = 10.0
var tiempo_transcurrido: float = 0.0

@onready var sprite := $Sprite2D
@onready var luz := $PointLight2D
@onready var timer := $FadeOut

func _ready():
	timer.timeout.connect(_on_timer_timeout)
	
	# Aseguramos estado inicial
	sprite.modulate.a = 1.0
	luz.energy = 2.0

func _process(delta):
	tiempo_transcurrido += delta
	var t: float = clamp(tiempo_transcurrido / tiempo_total, 0.0, 1.0)
	
	# Fade lineal: de 1 a 0
	sprite.modulate.a = 1.0 - t
	luz.energy = 2.0 * (1.0 - t)

func _on_timer_timeout():
	queue_free()
