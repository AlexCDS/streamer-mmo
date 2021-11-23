extends Control

func _on_Button_button_up():
	Online.connectToServer($Ip.text)
	queue_free()
	pass
