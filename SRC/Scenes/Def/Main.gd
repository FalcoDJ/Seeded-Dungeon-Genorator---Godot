extends Control

onready var container = $Container

func _on_Button_got_rooms(rooms) -> void:
	for child in container.get_children():
		child.queue_free()
	
	for room in rooms:
		var rect : ColorRect = ColorRect.new()
		rect.rect_position = room.position
		rect.rect_size = room.size
		container.add_child(rect)
		var color = Color(randf(),randf(),randf(), 0.75)
		rect.set_deferred("color", color)
