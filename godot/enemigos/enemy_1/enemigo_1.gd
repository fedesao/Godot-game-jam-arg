extends CharacterBody2D
@export var vida = Global.enemigo_1_vida
@export var speed = Global.enemigo_1_speed
var player
signal enemigo_muere

func _ready():
	player = get_node("../Player")


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func take_damage(dmgDone):
	vida -= dmgDone
	print("recibio daño")
	if vida <= 0:
		enemigo_muere.emit()
		queue_free()


func _on_enemigo_muere() -> void:
	pass # sumar puntos?
