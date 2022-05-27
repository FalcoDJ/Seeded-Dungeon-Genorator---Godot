extends Button

signal got_rooms(rooms)

func _on_Button_pressed():
	emit_signal("got_rooms", ProcDunj.GenerateDungeon(100,192,192,80,88991213,64,64))
