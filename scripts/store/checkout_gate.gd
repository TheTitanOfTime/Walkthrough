class_name CheckoutGate
extends RefCounted


static func allows(current: SessionState) -> bool:
	return current != null and current.required_complete()
