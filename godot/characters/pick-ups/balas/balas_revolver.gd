extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("agregar_municion"):
		body.agregar_municion("revolver", 10)
		print("municion revolver recogida")
		queue_free()
