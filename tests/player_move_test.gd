extends RefCounted

const PlayerScript := preload("res://scripts/store/player.gd")


func test() -> bool:
	if PlayerScript.axes(true, false, false, false) != Vector2(0, -1):
		return false
	if PlayerScript.axes(false, true, false, false) != Vector2(0, 1):
		return false
	if PlayerScript.axes(false, false, true, false) != Vector2(-1, 0):
		return false
	if PlayerScript.axes(false, false, false, true) != Vector2(1, 0):
		return false
	if PlayerScript.axes(true, true, true, true) != Vector2.ZERO:
		return false
	var diagonal: Vector2 = PlayerScript.axes(true, false, true, false)
	return diagonal.length() > 0.99 and diagonal.length() < 1.01
