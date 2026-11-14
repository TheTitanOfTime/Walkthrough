extends RefCounted

const SessionState := preload("res://scripts/domain/session_state.gd")
const CheckoutGate := preload("res://scripts/store/checkout_gate.gd")


func test() -> bool:
	return _allows_when_complete(1, 3) and _allows_when_complete(2, 4) and _allows_when_complete(3, 5)


func _allows_when_complete(level_number: int, expected: int) -> bool:
	var state := SessionState.new()
	if not state.start_level(level_number):
		return false
	if state.level.zone_ids.size() != expected:
		return false
	if CheckoutGate.allows(state):
		return false
	for zone_id in state.level.zone_ids:
		state.collect(zone_id)
	return CheckoutGate.allows(state)
