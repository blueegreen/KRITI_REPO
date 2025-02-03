extends Camera2D
class_name LevelCamera

enum state {FREE, FOLLOW}
var _current_state : state = state.FOLLOW

@export var base_shake_length := 5.0
@export var follow_speed := 1.0

@export var level_max_zoom := Vector2(0.9, 0.9)

var _player : Player
var _shake_tween : Tween
var _move_tween : Tween
var _init_zoom : Vector2

func _ready():
	GlobalRef.camera_ref = self
	_player = get_tree().get_first_node_in_group("player")
	_init_zoom = zoom

func _process(delta):
	match _current_state:
		state.FREE:
			return
		state.FOLLOW:
			follow_player(delta)

func follow_player(delta):
	if _player:
		global_position = global_position.lerp(_player.global_position, 1 - exp(-4.0*delta))

func screen_shake(strength: float = 1.0, duration: float = 0.2):
	if _shake_tween:
		_shake_tween.kill()
	_shake_tween = create_tween()
	_shake_tween.tween_property(self, "offset", strength * Vector2(randf_range(-base_shake_length, base_shake_length), randf_range(-base_shake_length, base_shake_length)), duration / 4.0)
	_shake_tween.tween_property(self, "offset", strength * Vector2(randf_range(-base_shake_length, base_shake_length), randf_range(-base_shake_length, base_shake_length)), duration / 4.0)
	_shake_tween.tween_property(self, "offset", strength * Vector2(randf_range(-base_shake_length, base_shake_length), randf_range(-base_shake_length, base_shake_length)), duration / 4.0)
	_shake_tween.tween_property(self, "offset", strength * Vector2(randf_range(-base_shake_length, base_shake_length), randf_range(-base_shake_length, base_shake_length)), duration / 4.0)
	_shake_tween.tween_callback(reset_shake)

func reset_shake():
	offset = Vector2(0, 0)

func track_boss_attack(_boss:Node2D):
	#_current_state = state.FREE
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween().set_parallel()
	#_move_tween.tween_property(self, "global_position", 0.5 * (boss.global_position + _player.global_position), 3.0).set_ease(Tween.EASE_IN_OUT)
	_move_tween.tween_property(self, "zoom", level_max_zoom, 2.0).set_ease(Tween.EASE_IN_OUT)

func track_player():
	if _move_tween:
		_move_tween.kill()
	_current_state = state.FOLLOW
	_move_tween = create_tween() 
	_move_tween.tween_property(self, "zoom", _init_zoom, 3.0).set_ease(Tween.EASE_IN_OUT)
