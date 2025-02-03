extends Sprite2D
class_name MoleSkin

@export var anim_player : AnimationPlayer
var _no_change := false

#func _process(delta):
	#print(anim_player.current_animation)

func orient(dir: Vector2):
	set_flip_h(dir.x < 0)

func idle():
	if anim_player.has_animation("idle"):
		if anim_player.current_animation != "idle" and not _no_change:
			anim_player.play("idle")

func run():
	if anim_player.has_animation("run"):
		if anim_player.current_animation != "run" and not _no_change:
			anim_player.play("run")

func hurt():
	if anim_player.has_animation("hurt"):
		anim_player.play("hurt")
		_no_change = true
		await anim_player.animation_finished
		_no_change = false

func die():
	if anim_player.has_animation("dead"):
		if anim_player.current_animation != "dead" and not _no_change:
			anim_player.play("dead")

func stun():
	if anim_player.has_animation("stun"):
		if anim_player.current_animation != "stun" and not _no_change:
			anim_player.play("stun")
