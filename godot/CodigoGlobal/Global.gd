extends Node

#var player
var playerLife:int = 100
var playerSpeed:float = 50.0
var playerDmg:float = 5.0
var balasDisponibles:int = 6 #a revisar
var puntaje:int = 0

### VAR ARMAS
#pistola
var balaSpeed1:float = 200.0
var balaDmg1:int = 5

var revolver_actual_ammo_held:int = 10
var revolver_max_ammo_held:int = 40
var escopeta_max_ammo_held:int = 48
#escopeta
var escopetaSpeed:float = 150.0
var escopetaDmg:int = 2

var escopeta_actual_ammo_held:int = 10


#enemigos
var enemigo_1_vida:int = 12
var enemigo_1_speed:float = 60.0
var enemyDmg:int = 4
var chancho_lata_vida:int = 30
var luz_mala_dmg:int = 45
var chanchoDmg:int = 35
