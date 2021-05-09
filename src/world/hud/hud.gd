extends Control
## HUD



## Refrences
const Event := preload("res://src/world/hud/event/event.tscn")



## OnReady Variables
onready var events : VBoxContainer = get_node("Events")

onready var speed_value : HSlider = get_node("Controls/VBoxContainer/Speed/Value")



## Built-In Virtual Methods
func _process(delta : float) -> void:
	visible = not get_tree().paused
	
	for event in events.get_children():
		if event.modulate.a <= 0.0:
			events.remove_child(event)
			event.queue_free()
		event.modulate.a -= 0.01



## Public Methods
func add_event(text : String) -> void:
	var event := Event.instance()
	event.text = text
	events.add_child(event)



## Private Methods
func _on_Speed_Value_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_RIGHT:
				speed_value.value = 1.0
				get_tree().set_input_as_handled()


func _on_Speed_Value_value_changed(value : float):
	Engine.time_scale = value
