class_name LevelConfig
extends Resource

enum CheckoutKind { SELF, CASHIER }

@export var level_number: int
@export var npc_count: int
@export var zone_ids: PackedStringArray
@export var checkout: CheckoutKind

const LABELS := {
	"milk": "Milk",
	"bread": "Bread",
	"apples": "Apples",
	"eggs": "Eggs",
	"rice": "Rice",
}


static func label_for(zone_id: String) -> String:
	return str(LABELS.get(zone_id, zone_id))


static func load_number(level_number: int) -> LevelConfig:
	var path := "res://resources/levels/level_%d.tres" % level_number
	if not ResourceLoader.exists(path):
		return null
	return load(path) as LevelConfig


static func load_all() -> Array[LevelConfig]:
	var levels: Array[LevelConfig] = []
	for number in [1, 2, 3]:
		var level := load_number(number)
		if level != null:
			levels.append(level)
	return levels


func checkout_name() -> String:
	if checkout == CheckoutKind.CASHIER:
		return "Cashier"
	return "Self checkout"


func button_text() -> String:
	return "Level %d\n%d people\n%d zones\n%s" % [
		level_number,
		npc_count,
		zone_ids.size(),
		checkout_name(),
	]
