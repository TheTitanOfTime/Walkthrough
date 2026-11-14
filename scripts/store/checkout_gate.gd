class_name CheckoutGate
extends RefCounted

const SessionState := preload("res://scripts/domain/session_state.gd")


static func allows(current: SessionState) -> bool:
	return current != null and current.required_complete()
