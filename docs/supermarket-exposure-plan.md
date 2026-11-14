# Build the supermarket session

A therapist runs a grocery-store session in the browser and picks one of three intensities for the patient. You are done when that loop works in a Godot 4.7.2 web export. Any person or coding agent can build it from this file. No plugin, runner, or model is required.

The patient sees a start screen, picks nothing, and walks a single store. The therapist uses the level select screen. One scene serves every level. A `LevelConfig` resource holds the intensity. A `SessionState` object holds the phase and the collected items.

Humans build the store in the Godot editor. Code writes the scripts, the tests, the level resources, the in-game screens, and a therapist page in `site/`. The two tracks edit different paths, so they can land at the same time.

Godot 4.7.2 is required to build the store, run the headless check, and export the game. `addons/GodotTogether/src/scripts/GodotTogether.gd` pins that version, and `project.godot` tags 4.7. The therapist page does not need Godot.

## Status

Implemented.

- The start screen is `Scenes/app/start.tscn`. The title is `supermarket` and the button says `Start`.
- Level select is `Scenes/app/level_select.tscn`. The three buttons are built from the level resources.
- The counter, the item list, `Pay`, and the cashier `Next` prompts are built by `scripts/store/checkout.gd`.
- `project.godot` opens `res://Scenes/app/start.tscn` and loads the `Session` autoload. Do not point the main scene at the store UID.
- The session rules, the three level resources, and the headless tests are in place.
- Store logic scripts live under `scripts/store/` (`player.gd`, `grocery_zone.gd`, `shopper.gd`, `shopper_spawner.gd`, plus the existing gate and checkout scripts).
- Browser demo is one site: therapist opens `build/web/index.html` (from `site/index.html`), selects a mode, and the patient plays `play/index.html?level=N` in the store. No in-game Start/level-select on that path. Checkout returns to the therapist page. Use `Scripts/serve_web_demo.sh`.
- `ShopperSpawner` instances `LevelConfig.npc_count` shoppers on the nav mesh and skips points near shelf-like nodes. Grocery zones show a translucent marker so the patient can find them.
- Until `Scenes/store/store.tscn` exists, `Scenes/app/session.tscn` shows checkout plus `Enter` buttons from `scripts/app/session_screen.gd`. Each button calls `collect` for one zone on the active level.

Not implemented.

- Polished shopper art (capsule stand-ins spawn until `shopper_scene` is set).

`Scenes/store/store.tscn` is wired from the supermarket art blockout: `Player`, five grocery zones, `Navigation`, `ShopperSpawner`, `Checkout`, and `Cashier`. `Session.begin_level` opens that scene. Zone positions are approximate near shelves and can be nudged in the editor.

Web export uses preset `Web` in `export_presets.cfg` (threads off, `addons/GodotTogether/` excluded). Output is `build/web/` (gitignored). Rebuild with:

```
godot --headless --path . --export-release "Web" build/web/index.html
```

Prefer `scripts/serve_web_demo.sh` (exports into `build/web/play/`, copies the therapist page to `build/web/index.html`, serves port 8077). Open `http://127.0.0.1:8077/` first.

## Attach the store scripts

Humans create `Scenes/store/store.tscn` in the editor. Code does not write that folder. Attach each script to the node name in this table. The game finds those names.

| Node name | Type | Script |
| --- | --- | --- |
| `Player` | `CharacterBody3D` | `res://scripts/store/player.gd` |
| `ZoneMilk` | `Area3D` | `res://scripts/store/grocery_zone.gd` |
| `ZoneBread` | `Area3D` | `res://scripts/store/grocery_zone.gd` |
| `ZoneApples` | `Area3D` | `res://scripts/store/grocery_zone.gd` |
| `ZoneEggs` | `Area3D` | `res://scripts/store/grocery_zone.gd` |
| `ZoneRice` | `Area3D` | `res://scripts/store/grocery_zone.gd` |
| `Navigation` | `NavigationRegion3D` | none |
| `ShopperSpawner` | `Node3D` | `res://scripts/store/shopper_spawner.gd` |
| `Checkout` | `Node3D` | `res://scripts/store/checkout.gd` |
| `Cashier` | `Node3D` | none |

`player.gd` reads WASD and the arrow keys with `Input.is_physical_key_pressed`. It does not use an input map or mouse look. It adds the body to the `player` group. It creates a `Camera3D` when the node has none, makes that camera current, and keeps it behind the body. Add a `CollisionShape3D` on `Player`. Without a shape, the body falls.

Set `zone_id` on each grocery zone to `milk`, `bread`, `apples`, `eggs`, or `rice`, matching the node. Put the zone mesh and a `CollisionShape3D` under the `Area3D`. `grocery_zone.gd` calls `ZoneGate.keeps`. A zone that is not on the active level hides, disables its collision shape, and does not call `collect`. On enter, the zone calls `Session.state.collect` only for a body named `Player` or a body in the `player` group, and only when `ZoneGate.keeps` is true for that id.

`shopper_spawner.gd` reads `Session.state.level.npc_count` and instances that many shoppers. Level 1 instances none. It searches the current scene for a `NavigationRegion3D` named `Navigation`. A node with that name and a different type is ignored. The spawner does not instance `Cashier`. Leave the `shopper_scene` export empty to use a capsule `CharacterBody3D` with `res://scripts/store/shopper.gd`. To use people art, assign a packed scene whose root is a `CharacterBody3D`. The spawner attaches `shopper.gd` to that root and removes the `player` group. `shopper.gd` walks to a random point on that navigation map, waits, and repeats. It never calls `collect`.

Place `Checkout` at the front of the store. Place `Cashier` at the front with no script.

After the nodes exist, link the store to the session.

1. Save the scene as `res://Scenes/store/store.tscn`. `Session.begin_level` already opens that path when the file exists, and opens `Scenes/app/session.tscn` until then.
2. Add a floor the player and the shoppers can stand on. Bake `Navigation` after the floor and walls are in place. Put `ShopperSpawner` on that floor.
3. Play level 1 and walk the player into each active zone. `N of M` rises once per zone. Entering the same zone again does not raise N. Eggs and rice stay hidden.
4. Play level 2. Ten shoppers spawn. A shopper that crosses a zone leaves the counter unchanged.
5. Play level 3. Five zones show, twenty shoppers walk, and the cashier `Next` prompts run only when the list is complete.
6. Export the web build after that scene exists. Thread support stays off. Keep `site/index.html` out of `build/web`. Serve the export with `python3 -m http.server 8077`. The therapist page links `http://127.0.0.1:8077/`.

`scripts/app/session_screen.gd` stays on `Scenes/app/session.tscn` only. Its `Enter` buttons sit above the checkout panel so `Pay` and cashier `Next` can be tried before the store scene exists. The store scene does not use that script.

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
| `scripts/store/checkout.gd` | Implemented. Kiosk or cashier UI, built by the script |
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

1. Implemented. The types, the three resources, `tests/session_test.gd`, `tests/zone_gate_test.gd`, and `tests/checkout_gate_test.gd` are in the repo. When Godot is installed, run the headless check. The log must contain every line under How to check.
2. Implemented. `site/index.html` uses the title `supermarket`, lists the three levels, and links the game at `http://127.0.0.1:8077/`. Keep this file out of `build/web`. Godot overwrites that folder on export.
3. Implemented. The start screen and level select are under `Scenes/app/`. `Start` opens level select. Each button is filled from its resource.
4. Implemented. Store scripts under `scripts/store/` use the node names above. They do not create the floor, the meshes, or the zones.
5. Implemented. `export_presets.cfg` has the `Web` preset (thread support off, GodotTogether excluded). Export to `build/web/index.html`. Serve `build/web` with `python3 -m http.server 8077`.

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
