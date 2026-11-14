# Build the supermarket session

A therapist runs a grocery-store session in the browser and picks one of three intensities for the patient. You are done when that loop works in a Godot 4.7.2 web export. Any person or coding agent can build it from this file. No plugin, runner, or model is required.

The patient sees a start screen, picks nothing, and walks a single store. The therapist uses the level select screen. One scene serves every level. A `LevelConfig` resource holds the intensity. A `SessionState` object holds the phase and the collected items.

Install Godot 4.7.2 before you start. `addons/GodotTogether/src/scripts/GodotTogether.gd` pins that version, and `project.godot` tags 4.7. This machine may not have `godot` on `PATH`.

## The session

1. The page loads on a start screen. The title is `supermarket`. The button says `Start`.
2. `Start` opens level select. Three buttons are built from the three level resources.
3. A level button starts that level and opens the store.
4. The patient walks freely and collects an item by entering its zone. The screen shows `N of M` and the item label. Entering the same zone again does not raise N.
5. Checkout stands at the front of the store. A short list keeps the action disabled and shows how many items remain. A complete list finishes checkout and returns to level select.
6. The next level starts at zero collected items.

There is no second door after payment. Finishing checkout is the exit.

## Levels

| Level | Shoppers | Zone ids | Labels | Checkout |
| --- | --- | --- | --- | --- |
| 1 | 0 | `milk`, `bread`, `apples` | Milk, Bread, Apples | Self checkout |
| 2 | 10 | those three, plus `eggs` | plus Eggs | Self checkout |
| 3 | 20 | those four, plus `rice` | plus Rice | Cashier |

The cashier is a stationary character at the front of the store. Do not count the cashier among the 20 shoppers.

Each level button reads `Level N`, the people count, the zone count, and either `Self checkout` or `Cashier`. Example text for level 1 is `Level 1`, `0 people`, `3 zones`, `Self checkout`.

## Rules

`start_level` loads that resource, clears collected ids, and sets the phase to `SHOPPING`. An unknown level number leaves the phase unchanged and returns false. A second `start_level` clears the previous set.

`collect` returns true only the first time a required zone id is collected. An unknown zone id returns false and does not change the set.

`begin_checkout` stays in `SHOPPING` and returns false while any required zone is missing. It sets `CHECKOUT` and returns true when the list is complete. The kiosk and the cashier both call this function. They must not keep a second copy of the rule.

`finish_checkout` sets `LEVEL_SELECT` and clears collected ids only when the phase is `CHECKOUT`. From any other phase it returns false and changes nothing.

Shoppers walk. They never call `collect`.

Reloading the page starts a new session on the start screen.

## Types

Put the rules on `SessionState`. Keep Godot nodes out of that script so tests can construct it with `new`.

```gdscript
class_name LevelConfig
extends Resource

enum CheckoutKind { SELF, CASHIER }

@export var level_number: int
@export var npc_count: int
@export var zone_ids: PackedStringArray
@export var checkout: CheckoutKind
```

```gdscript
class_name SessionState
extends RefCounted

enum Phase { START, LEVEL_SELECT, SHOPPING, CHECKOUT }

var phase: Phase = Phase.START
var level: LevelConfig
var collected: Dictionary

func start_level(level_number: int) -> bool:
	return false

func collect(zone_id: String) -> bool:
	return false

func required_complete() -> bool:
	return false

func begin_checkout() -> bool:
	return false

func finish_checkout() -> bool:
	return false
```

The autoload `Session` is a `Node`. It holds one `SessionState` and changes scenes. It does not decide whether a zone counts.

Scene paths live on that autoload.

| Phase | Scene |
| --- | --- |
| `START` | `res://Scenes/app/start.tscn` |
| `LEVEL_SELECT` | `res://Scenes/app/level_select.tscn` |
| `SHOPPING` | `res://Scenes/store/store.tscn` |

`finish_checkout` is followed by a scene change to level select.

## Files

Create these. The `Scenes/` folder already exists. Use that capital S.

| File | Job |
| --- | --- |
| `scripts/domain/level_config.gd` | The resource above |
| `scripts/domain/session_state.gd` | The rules above |
| `scripts/domain/session.gd` | Autoload. Holds `SessionState` and changes scenes |
| `resources/levels/level_1.tres` | Level 1 row |
| `resources/levels/level_2.tres` | Level 2 row |
| `resources/levels/level_3.tres` | Level 3 row |
| `tests/run.gd` | Loads every `tests/*_test.gd`, calls `test()`, prints `session ok` only if all return |
| `tests/session_test.gd` | Prints the log lines in How to check |
| `Scenes/app/start.tscn` | Title and `Start` |
| `scripts/app/start.gd` | Opens level select |
| `Scenes/app/level_select.tscn` | Three buttons from the resources |
| `scripts/app/level_select.gd` | Calls `start_level`, then opens the store |
| `Scenes/store/store.tscn` | Floor, walls, player, five zones, nav region, spawner, kiosk, cashier |
| `Scenes/store/player.tscn` | `CharacterBody3D` |
| `scripts/store/player.gd` | WASD and arrow keys |
| `scripts/store/zone_gate.gd` | Pure function. Keeps a zone only when its id is on the active level |
| `scripts/store/grocery_zone.gd` | `Area3D`. On player enter, calls `collect` |
| `scripts/store/shopper.gd` | Walks a random navmesh point, waits, repeats |
| `scripts/store/shopper_spawner.gd` | Instances `npc_count` shoppers. Instances none when the count is 0 |
| `scripts/store/checkout_gate.gd` | Pure function. Allows checkout only when `required_complete` is true |
| `scripts/store/checkout.gd` | Kiosk or cashier UI |
| `export_presets.cfg` | Web export, thread support off |

Edit `project.godot` in two places only. Add the autoload `Session` at `res://scripts/domain/session.gd`. Set the main scene to `res://Scenes/app/start.tscn`.

## Build order

Do these in order. Finish the check for a step before the next step.

1. Add the types, the three resources, and `tests/session_test.gd`. Run the headless check. The log must contain every line under Session log.
2. Add the start screen and level select. `Start` opens level select. Each button is filled from its resource. Point the main scene at the start screen.
3. Add the greybox store and the player. The floor is 40 by 24 meters, with wall blocks and one red pillar. Use `CharacterBody3D`. Read WASD and the arrow keys with `Input.is_physical_key_pressed`. Do not add an input map. Lock the camera behind and above the body. Do not add mouse look. Level select opens this same scene for every level.
4. Add five zone markers, ids `milk`, `bread`, `apples`, `eggs`, and `rice`. Hide and disable a zone when `zone_gate.gd` rejects its id. Show `N of M` and the item label on the first collect.
5. Bake a `NavigationRegion3D` on the floor. Spawn `npc_count` shoppers with `NavigationAgent3D` and avoidance on. A shopper body must not call `collect`.
6. Add the kiosk and the cashier at the front of the store. For `SELF`, show the kiosk and hide the cashier. List collected labels. Enable `Pay` only when the gate allows it. `Pay` calls `begin_checkout`, then `finish_checkout`, then opens level select. For `CASHIER`, show the cashier and hide the kiosk. Three presses of `Next` show `Hello`, then the item labels, then `Goodbye`. `Goodbye` takes the same finish path. If the gate refuses, `Next` does not advance and the screen shows the remaining count.
7. Export the web build. Thread support is off. The renderer stays `gl_compatibility`. Exclude `addons/GodotTogether/` from the preset. Serve `build/web` with `python3 -m http.server 8077` and open `http://127.0.0.1:8077/`.

## How to check

From the project root, run this command.

```
godot --headless --path . --script res://tests/run.gd
```

`tests/session_test.gd` constructs `SessionState` directly. It does not use the autoload. The log contains these lines.

```
level 1 npc 0 zones 3 checkout self
level 2 npc 10 zones 4 checkout self
level 3 npc 20 zones 5 checkout cashier
checkout refused
checkout allowed
collected 1
zone rejected
phase level_select
collected cleared
level rejected
session ok
```

`checkout refused` is a short list. `checkout allowed` is a complete list. `collected 1` is a second enter of the same zone. `zone rejected` is an id the level does not list. `phase level_select` follows `finish_checkout`. `collected cleared` follows a second `start_level`. `level rejected` is an unknown level number. `session ok` is absent when any test fails.

Add `tests/zone_gate_test.gd` for the 3, 4, and 5 zone counts. Add `tests/checkout_gate_test.gd` for a short list and a full list at those same counts. The runner picks them up because their names end in `_test.gd`.

Then play these paths in the editor, and again in the exported page.

- Level 1 shows three zones, no shoppers, and a kiosk. Two items leave `Pay` disabled. Three items return to the three level buttons.
- Level 2 shows four zones, 10 shoppers, a kiosk, and no cashier. A shopper that crosses a zone leaves the counter unchanged.
- Level 3 shows five zones, 20 shoppers, a cashier, and no kiosk. Four items do not show `Hello`. Five items show `Goodbye` and then the three level buttons.
- After that return, level 1 starts at `0 of 3`.
- Reload in the middle of a shop shows `supermarket` and `Start`.

A headless load of the store at level 3, with 20 shoppers, for 300 frames, should print a mean `frame_ms` of 33 or less. Thirty-three milliseconds is one frame at 30 frames a second. If the number is higher, report it and stop. Do not change the renderer to chase it.

## Do not change

Leave `addons/GodotTogether/` as it is, including its folder name. Do not call `addons/GodotTogether/src/scripts/tests.gd` from the game tests. That script is the editor plugin boot check.

Leave `Scenes/test.tscn` unused. It is an empty `Node2D` and it is not the main scene.

Leave the Compatibility renderer in place. Forward+ and Mobile do not export to the web. Leave the `d3d12` line alone. It applies to Windows only.

Do not add accounts, a server, a saved progress file, a dialogue editor, a copied store per level, an on-screen joystick, or a therapist PIN. The page is open to anyone who has the link, and walking expects a keyboard.

## Risks

Jolt is the 3D physics engine in `project.godot`. A single-threaded web export froze on moving bodies in Godot 4.5 beta 6. That freeze was fixed on master. Walk the release build for two minutes. If the browser freezes, switch the 3D physics engine to Godot Physics, record the switch, and stop.

The store art is a grey floor, grey walls, and a red pillar. The loop can be tested on that art.

Godot 4.7 web export notes are at `https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html`. Jolt notes are at `https://docs.godotengine.org/en/4.7/tutorials/physics/using_jolt_physics.html`. The freeze report is `https://github.com/godotengine/godot/issues/109948`.
