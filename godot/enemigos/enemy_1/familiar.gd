extends CharacterBody2D
@export var vida = Global.enemigo_1_vida
@export var speed = Global.enemigo_1_speed
@onready var dmg = Global.enemyDmg
@onready var dmgTimer = %DmgTimer
var player_ref: Node = null

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
	Global.puntaje += 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		dmgTimer.start()


func _on_area_dmg_player_body_exited(body: Node2D) -> void:
		if body == player_ref:
			dmgTimer.stop()
			player_ref = null

func _on_dmg_timer_timeout() -> void:
		if player_ref and player_ref.has_method("take_damage_player"):
			player_ref.take_damage_player(dmg)
