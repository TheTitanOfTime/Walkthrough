# Build the supermarket session

A therapist runs a grocery-store session in the browser and picks one of three intensities for the patient. You are done when that loop works in a Godot 4.7.2 web export. Any person or coding agent can build it from this file. No plugin, runner, or model is required.

The patient sees a start screen, picks nothing, and walks a single store. The therapist uses the level select screen. One scene serves every level. A `LevelConfig` resource holds the intensity. A `SessionState` object holds the phase and the collected items.

Humans build the store in the Godot editor. Code writes the scripts, the tests, the level resources, the in-game screens, and a therapist page in `site/`. The two tracks edit different paths, so they can land at the same time.

Godot 4.7.2 is required to build the store, run the headless check, and export the game. `addons/GodotTogether/src/scripts/GodotTogether.gd` pins that version, and `project.godot` tags 4.7. The therapist page does not need Godot.

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

## Who edits what

The `Scenes/` folder already exists. Use that capital S.

Humans edit these paths in the Godot editor.

| Path | Job |
| --- | --- |
| `Assets/` | Models and textures, including the Kenney city kit |
| `Scenes/store/store.tscn` | The one store. Floor, walls, five zones, nav region, spawner, checkout, cashier |
| `Scenes/store/player.tscn` | The player body |

Code edits these paths.

| Path | Job |
| --- | --- |
| `scripts/domain/level_config.gd` | The resource above |
| `scripts/domain/session_state.gd` | The rules above |
| `scripts/domain/session.gd` | Autoload. Holds `SessionState` and changes scenes |
| `resources/levels/level_1.tres` | Level 1 row |
| `resources/levels/level_2.tres` | Level 2 row |
| `resources/levels/level_3.tres` | Level 3 row |
| `tests/run.gd` | Loads every `tests/*_test.gd`, calls `test()`, prints `session ok` only if all return |
| `tests/session_test.gd` | Prints the log lines in How to check |
| `tests/zone_gate_test.gd` | Zone counts 3, 4, and 5 |
| `tests/checkout_gate_test.gd` | Short list and full list at those counts |
| `Scenes/app/start.tscn` | In-game title and `Start` |
| `scripts/app/start.gd` | Opens level select |
| `Scenes/app/level_select.tscn` | Three buttons from the resources |
| `scripts/app/level_select.gd` | Calls `start_level`, then opens the store |
| `scripts/store/player.gd` | WASD and arrow keys. Locks the camera behind the body |
| `scripts/store/zone_gate.gd` | Pure function. Keeps a zone only when its id is on the active level |
| `scripts/store/grocery_zone.gd` | On player enter, calls `collect` |
| `scripts/store/shopper.gd` | Walks a random navmesh point, waits, repeats |
| `scripts/store/shopper_spawner.gd` | Instances `npc_count` shoppers. Instances none when the count is 0 |
| `scripts/store/checkout_gate.gd` | Pure function. Allows checkout only when `required_complete` is true |
| `scripts/store/checkout.gd` | Kiosk or cashier UI, built by the script |
| `export_presets.cfg` | Web export, thread support off |
| `site/index.html` | Therapist page. Links to the export. The patient does not play this page |

`Scenes/supermarket.tscn` is an empty `Node3D`. It is not the store.

Code writes two lines in `project.godot` once, before the editor saves the project. Add the autoload `Session` at `res://scripts/domain/session.gd`. Set the main scene to `res://Scenes/app/start.tscn`. After that first editor save, only humans commit `project.godot`.

## Nodes the store must contain

Humans create these nodes and attach the scripts. Code finds the nodes by these names. Code does not write `Scenes/store/`.

| Name | Type | Script |
| --- | --- | --- |
| `Player` | `CharacterBody3D` | `res://scripts/store/player.gd` |
| `ZoneMilk` | `Area3D` | `res://scripts/store/grocery_zone.gd`, zone id `milk` |
| `ZoneBread` | `Area3D` | same script, zone id `bread` |
| `ZoneApples` | `Area3D` | same script, zone id `apples` |
| `ZoneEggs` | `Area3D` | same script, zone id `eggs` |
| `ZoneRice` | `Area3D` | same script, zone id `rice` |
| `Navigation` | `NavigationRegion3D` | none. Humans bake the mesh |
| `ShopperSpawner` | `Node3D` | `res://scripts/store/shopper_spawner.gd` |
| `Checkout` | `Node3D` at the front of the store | `res://scripts/store/checkout.gd` |
| `Cashier` | `Node3D` at the front of the store | none. The cashier is not a shopper |

Keep a floor about 40 by 24 meters until the art replaces it. A red pillar is enough for a walk test. `player.gd` reads WASD and the arrow keys with `Input.is_physical_key_pressed`. Do not add an input map. The camera stays behind the body. Do not add mouse look.

`checkout.gd` shows the kiosk for `SELF` and the cashier prompts for `CASHIER`. `Pay`, and the `Goodbye` step, call `begin_checkout`, then `finish_checkout`, then open level select. A short list shows the remaining count and does not advance. Three presses of `Next` show `Hello`, then the item labels, then `Goodbye`.

## Build order

These two lists do not share files.

Code can start before Godot is installed. The headless check waits until `godot` is on `PATH`.

1. Add the types, the three resources, and `tests/session_test.gd`. When Godot is installed, run the headless check. The log must contain every line under How to check.
2. Add `site/index.html`. Use the title `supermarket`. List the three levels with their people counts, zone counts, and checkout kind. Link the game at `http://127.0.0.1:8077/`. Keep this file out of `build/web`. Godot overwrites that folder on export.
3. Add the start screen and level select under `Scenes/app/`. `Start` opens level select. Each button is filled from its resource.
4. Add the store scripts. They use the node names above. They do not create the floor, the meshes, or the zones.
5. Export the web build after `Scenes/store/store.tscn` exists. Thread support is off. The renderer stays `gl_compatibility`. Exclude `addons/GodotTogether/` from the preset. Serve `build/web` with `python3 -m http.server 8077`.

Humans start when Godot 4.7.2 is installed.

1. Build `Scenes/store/player.tscn` and `Scenes/store/store.tscn` with the nodes listed above.
2. Place the five zones. Leave every zone in the scene. `zone_gate.gd` hides a zone when the active level does not list its id.
3. Bake `Navigation`.
4. Place `Checkout` and `Cashier` at the front. Do not attach `shopper.gd` to the cashier.

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

Humans do not edit `scripts/`, `tests/`, `resources/levels/`, `Scenes/app/`, `site/`, or `export_presets.cfg`. Code does not edit `Assets/` or `Scenes/store/`.

Leave the Compatibility renderer in place. Forward+ and Mobile do not export to the web. Leave the `d3d12` line alone. It applies to Windows only.

Do not add accounts, a server, a saved progress file, a dialogue editor, a copied store per level, an on-screen joystick, or a therapist PIN. The page is open to anyone who has the link, and walking expects a keyboard.

## Risks

Jolt is the 3D physics engine in `project.godot`. A single-threaded web export froze on moving bodies in Godot 4.5 beta 6. That freeze was fixed on master. Walk the release build for two minutes. If the browser freezes, switch the 3D physics engine to Godot Physics, record the switch, and stop.

The store art can start as a grey floor, grey walls, and a red pillar. The loop can be tested on that art. Humans replace it in `Scenes/store/` and `Assets/` without editing scripts.

`project.godot` is shared only for the first autoload and main-scene edit. After the editor saves the project, a second code edit to that file will conflict with the human save.

Godot 4.7 web export notes are at `https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html`. Jolt notes are at `https://docs.godotengine.org/en/4.7/tutorials/physics/using_jolt_physics.html`. The freeze report is `https://github.com/godotengine/godot/issues/109948`.
