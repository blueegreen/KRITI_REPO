extends Area2D

@export var wait_time := 0.8;
@export var spawn_point := Vector2(0, 0)
@export var damage := 2.;
@onready var shock_sprite = $shock_sprite
var lightning_scene = preload("res://Bosses/Boss2/lightning_attack.tscn")

func _ready():
	$Timer.wait_time = wait_time
	$Timer.start()
	shock_sprite.modulate = Color(Color.AQUA, 0)
	var tween = create_tween()
	tween.tween_property(shock_sprite, "modulate", Color(Color.AQUA, 0.6), wait_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(shock_sprite, "modulate", Color(Color.AQUA, 0), 0.3).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _on_timer_timeout():
	deal_damage()

func deal_damage():
	$GPUParticles2D.emitting = true
	$AudioStreamPlayer2D.play()
	var lightning : Line2D = lightning_scene.instantiate()
	lightning.set_point_position(0, spawn_point)
	lightning.set_point_position(3, global_position)
	lightning.set_point_position(1, (spawn_point + global_position) / 2 + Vector2(randf_range(-50, 50), randf_range(-50, 50)))
	lightning.set_point_position(2, (spawn_point + global_position) / 2 + Vector2(randf_range(-50, 50), randf_range(-50, 50)))
	add_child(lightning)
	for area in get_overlapping_areas():
		if area.has_method("take_damage") and not area is BossHitbox:
			area.take_damage(damage, self)
