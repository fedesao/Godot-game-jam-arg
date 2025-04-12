extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("agregar_municion"):
		body.agregar_municion("escopeta", 4)
		print("municion escopeta recogida")
		queue_free()
