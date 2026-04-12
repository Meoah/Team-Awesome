extends MinigamePopup
class_name BossMinigamePopup

@export var _boss_bgm: AudioStream

func _ready() -> void:
	if _boss_bgm: _default_bgm = _boss_bgm
	super._ready()

func _pick_fish() -> int:
	return 21 #whatever the boss fish is

func _choose_variant() -> FishVariantType:
	return FishVariantType.NORMAL

func _choose_rarity() -> FishRarityType:
	return FishRarityType.LEGENDARY

func _win():
	SystemData.boss_defeated = true
	super._win()
