extends CharacterBody3D

## Movement helpers for headless tests. The store Player node uses res://scripts/Player.gd.


static func axes(forward: bool, back: bool, left: bool, right: bool) -> Vector2:
	var input := Vector2.ZERO
	if forward:
		input.y -= 1
	if back:
		input.y += 1
	if left:
		input.x -= 1
	if right:
		input.x += 1
	if input.length_squared() > 1.0:
		input = input.normalized()
	return input
