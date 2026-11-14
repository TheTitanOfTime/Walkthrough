extends RefCounted


func test() -> bool:
	var state := SessionState.new()
	if not _print_level(state, 1):
		return false
	if not _print_level(state, 2):
		return false
	if not _print_level(state, 3):
		return false
	if not state.start_level(1):
		return false
	state.collect("milk")
	state.collect("bread")
	if state.begin_checkout():
		return false
	print("checkout refused")
	state.collect("apples")
	if not state.begin_checkout():
		return false
	print("checkout allowed")
	var once := SessionState.new()
	once.start_level(1)
	once.collect("milk")
	once.collect("milk")
	if once.collected.size() != 1:
		return false
	print("collected 1")
	var rejected := SessionState.new()
	rejected.start_level(1)
	if rejected.collect("soap"):
		return false
	print("zone rejected")
	if not state.finish_checkout():
		return false
	if state.phase != SessionState.Phase.LEVEL_SELECT:
		return false
	print("phase level_select")
	var cleared := SessionState.new()
	cleared.start_level(2)
	cleared.collect("milk")
	if not cleared.start_level(3):
		return false
	if cleared.collected.size() != 0:
		return false
	print("collected cleared")
	var phase_before := cleared.phase
	if cleared.start_level(99):
		return false
	if cleared.phase != phase_before:
		return false
	print("level rejected")
	return true


func _print_level(state: SessionState, number: int) -> bool:
	if not state.start_level(number):
		return false
	var kind := "self"
	if state.level.checkout == LevelConfig.CheckoutKind.CASHIER:
		kind = "cashier"
	print(
		"level %d npc %d zones %d checkout %s"
		% [state.level.level_number, state.level.npc_count, state.level.zone_ids.size(), kind]
	)
	return true
