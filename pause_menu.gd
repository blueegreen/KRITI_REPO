extends Control
@onready var base_level: Node = $".."
@onready var PauseMenu_Sprite: Control = $"."
@onready var pause_slider: NinePatchRect = $NinePatchRect
@onready var tv_shader: ColorRect = $tv_shader
@onready var label: Label = $Label
@export var buttons : Array[Button]

func _ready() -> void:
	PauseMenu_Sprite.hide()
	pause_slider.set_global_position(Vector2(900,-592))
	
func _on_resume_pressed() -> void:
	if get_tree().paused:
		resume_game()

	
func _on_quit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause") and !get_tree().paused:
		pause_game()
	elif event.is_action_pressed("Pause") and get_tree().paused:
		resume_game()

func pause_game():
	var tween = get_tree().create_tween().bind_node(self)
	#tween.tween_property(pause_slider,"position",Vector2(-130,-600),0.2)
	tween.tween_property(pause_slider,"modulate",Color(0.562,0.324,0.258,0.2),0.0)
	tween.tween_property(pause_slider,"position",Vector2(-472,-592),0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel()
	tween.tween_property(pause_slider,"modulate",Color(0.562,0.324,0.258,1),0.25)
	
	get_tree().paused = true
	
	var rect = get_viewport_rect()
	
	#for i in range(buttons.size()):
		#var tween2 = create_tween().set_trans(Tween.TRANS_LINEAR)
		#tween2.tween_property(buttons[i],"position",Vector2(270,-176) + Vector2.DOWN * i * 75,0.0)
		#tween2.tween_property(buttons[i],"modulate",Color(1,1,1,0),0.0)
		#tween2.tween_property(buttons[i],"position",Vector2(224,167) + Vector2.DOWN * i * 75,0.25)
		#tween2.set_parallel(true).tween_property(buttons[i],"modulate",Color(1,1,1,1),0.25)
		##await get_tree().create_timer(0.2).timeout
	
	
	PauseMenu_Sprite.show()
	label.hide()
	for i in range(buttons.size()):
		buttons[i].hide()
	await get_tree().create_timer(0.25).timeout
	label.show()
	for i in range(buttons.size()):
		buttons[i].show()
	
func resume_game():
	label.hide()
	for i in range(buttons.size()):
		buttons[i].hide()
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(pause_slider,"position",Vector2(-1100,-592),0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel()
	tween.tween_property(pause_slider,"modulate",Color(0.562,0.324,0.258,0.1),0.25)
	tween.tween_property(pause_slider,"position",Vector2(900,-592),0.0)
	tween.tween_property(pause_slider,"modulate",Color(0.562,0.324,0.258,1),0.0)
	
	
	await get_tree().create_timer(0.25).timeout
	get_tree().paused= false
	PauseMenu_Sprite.hide()




func _on_main_menu_pressed() -> void:
	print("hi")
	get_tree().change_scene_to_file("res://settiings.gd")
	
#func _process(delta: float) -> void:
	#pause_slider.hide()
