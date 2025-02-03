extends CanvasLayer

@export var possible_powerups : Array[GlobalPowerupManager.Powerup]
@export var num_of_cards := 3
var powerup_card_scene = preload("res://powerup_management/powerup_card.tscn")
var cards := []
@onready var color_rect = $ColorRect

func _ready():
	color_rect.modulate = Color(1, 1, 1, 0)

func _process(delta):
	if Input.is_action_just_pressed("left"):
		start()

func start():
	var fade_tween = create_tween()
	fade_tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 1), 0.3).set_ease(Tween.EASE_IN)
	
	
	for c in cards:
		c.queue_free()
	cards.clear()
	
	var powerup_choices = possible_powerups.duplicate()
	for n in range(num_of_cards):
		var new_card : PowerupCard = powerup_card_scene.instantiate()
		var rand_num = randi_range(0, powerup_choices.size() - 1)
		if rand_num >= 0 and rand_num < powerup_choices.size():
			new_card.powerup = powerup_choices[rand_num]
			powerup_choices.pop_at(rand_num)
			add_child(new_card)
			cards.push_back(new_card)
			new_card.selected.connect(finish)
	
	var screen_size = get_viewport().get_visible_rect()
	var gap = (1200 - (287 * cards.size())) / (cards.size())
	for k in range(cards.size()):
		cards[k].position = Vector2(screen_size.size.x/2 + (gap + 287) * (k - int(cards.size()/2.0)), screen_size.size.y/2.0)
		if cards.size() % 2 == 0:
			cards[k].position.x += 143 + gap
		cards[k].rotation = (cards[k].position.x - screen_size.size.x/2) / 1500.0
		cards[k].position.y += pow(abs(int(cards.size()/2.0) - k), 2) * 40

func finish(card):
	var fade_tween = create_tween()
	fade_tween.tween_property(color_rect, "modulate", Color(1, 1, 1, 0), 0.3).set_ease(Tween.EASE_IN)
	for c in cards:
		if c != card:
			var tween = create_tween()
			tween.tween_property(c, "position", c.position + Vector2.DOWN * 1000, 1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tween.set_parallel(true).tween_property(c, "rotation", c.rotation + 2*PI, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
