# Supermarket exposure plan

Therapists run a grocery-store session in the browser and pick one of three intensities for the patient. One store scene covers every level. The patient gets a start screen, a level select screen, free walking, zone pickups, then checkout, then level select again.

The program enforces the verification rule in How to read this. The PR order is PR-1, PR-2, PR-3, PR-4, PR-5, PR-6, then PR-7. The operator lands every PR. No owner merges.

## How to read this

One box is one unit of work. Every box names the evidence that checks it. A nested box is a sub-step of the box above it. Check a box only when its evidence exists, a file, a log line, a screenshot, a test run, or a SHA. The body is a how-to. The appendices explain and record.

The program runs `pstack/skills/poteto-mode/playbooks/autopilot-stack.md`. The operator lands PR-1 through PR-7. Every PR stops at merge-ready. No owner merges.

Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

## Program checklist

### Arm the program

- [ ] State the protocol and this plan to the operator, then stop. Start execution only on the operator's explicit go.
- [ ] Read these from trunk at program start. Re-read them at every tick. This repo's `main` has no pstack tree. When `git show` fails, read the same file from the local pstack plugin cache and record that fallback.
  - [ ] `git show origin/main:pstack/skills/poteto-mode/playbooks/autopilot-stack.md`
  - [ ] `git show origin/main:pstack/skills/swarm/SKILL.md`
  - [ ] `git show origin/main:pstack/skills/control-ui/SKILL.md`
  - [ ] `git show origin/main:pstack/skills/poteto-mode/playbooks/opening-a-pr.md`
  - [ ] `git show origin/main:pstack/skills/principle-model-the-domain/SKILL.md`
  - [ ] `git show origin/main:pstack/skills/principle-prove-it-works/SKILL.md`
- [ ] On the operator's go, arm the audit tick as `/loop 1h` with the tick prompt below. Never leave the cadence to memory.
- [ ] Use this tick prompt, verbatim. "Re-read the execution playbook from trunk. Audit the operation against it and fix drift in this tick. Probe every active lane and judge progress by side effects only. Stand down a stuck lane and dispatch its replacement now. Then post a short status message to the operator in chat only when the audit found a tracked change that no earlier status message reported, such as a PR opened, a code-ready head, a round launched or closed, a verdict, a merge, a stuck agent and the action taken, a blocker added or cleared, or a decision only the operator can make. Name every such change and nothing else. Do not repeat a table, the merged list, or an unchanged blocker. If the audit found none, end the turn with no reply text. Either way, log this tick's row in your decision trail. The row names the items reported, or none."
- [ ] On the operator's hold or stand-down, send every owner a zero-writes order at once.

### Spawn owners

- [ ] Spawn one owner per PR with the full lifecycle the execution playbook names.
- [ ] Follow this dependency graph. Start dependent work only after its parent merges, or base it on the parent branch when the execution playbook stacks.
  - [ ] PR-1 is first and branches from `main`.
  - [ ] PR-2 after PR-1. PR-3 after PR-2. PR-4 after PR-3. PR-5 after PR-4. PR-6 after PR-5. PR-7 after PR-6.
- [ ] Hold the file boundaries. PR-1 touches `scripts/domain/**`, `resources/levels/**`, `tests/run.gd`, and `tests/session_test.gd`, plus the Session autoload line in `project.godot`. PR-2 touches `Scenes/app/**`, `export_presets.cfg`, and the main-scene line in `project.godot`. PR-3 touches `Scenes/store/**`, `scripts/store/player.gd`, `scripts/store/frame_stats.gd`, `tests/store_smoke.gd`, `tests/frame_store.gd`, and the one shopping path string in `scripts/domain/session.gd`. PR-4 touches `scripts/store/grocery_zone.gd`, `scripts/store/zone_gate.gd`, zone nodes in `Scenes/store/store.tscn`, and `tests/zone_gate_test.gd`. PR-5 touches `scripts/store/shopper.gd`, `scripts/store/shopper_spawner.gd`, the nav region and spawner in `Scenes/store/store.tscn`, and `tests/frame_crowd.gd`. PR-6 touches `scripts/store/checkout.gd`, `scripts/store/checkout_gate.gd`, the kiosk and cashier nodes in `Scenes/store/store.tscn`, and `tests/checkout_gate_test.gd`. PR-7 touches the release visibility line in `scripts/store/frame_stats.gd` and `tests/export_flags.gd`. No PR edits `addons/**` or `Scenes/test.tscn`.
- [ ] Hold the review gate. PR-2, PR-3, PR-4, PR-5, PR-6, and PR-7 change an interaction. They wait for the operator's review in chat with screenshots and a video before merge. PR-1 is not review-gated.

### PR mechanics, for every PR

- [ ] Resolve the forge once. Default to `gh`. If `command -v origin` succeeds and Origin can resolve the repository, use `origin pr` for every PR operation. Record any fallback to `gh`. Never require `gt`.
- [ ] Open the PR ready, never draft, per Opening a PR. Use the run's built-in PR tool when it has one, else `origin pr create --status open --base <base-branch>` or `gh pr create --base <base-branch>` according to the resolved forge. A stack child targets its parent branch.
- [ ] Run the repo's lint and typecheck once before the PR-facing push. This repo has no lint config. The check command is `godot --headless --path . --script res://tests/run.gd`. Push with hooks on.
- [ ] Run `/deslop` before each commit and `/no-comments` before review.
- [ ] Triage every Bugbot and security-reviewer comment per `pstack/skills/poteto-mode/references/bugbot-triage.md`.
- [ ] Rebase the stack root onto current trunk before the code-ready report and babysit. Rebase PR-2 through PR-7 onto the parent PR branch, not onto trunk. Keep that merge base in fix rounds. Rebase again only at merge prep, on a `git merge-tree` conflict with the parent, on a CI failure that comes from a change on the parent, or when a known concurrent change to the same files lands.

### Verdict and merge, for every PR

- [ ] A full swarm runs once, at the code-ready head. Another full swarm runs only for new behavior, a redesign, or a large new diff. A rebase, a merge-conflict resolution, or a minor fix gets a single verifier at the new head, and a wording-only change gets none. Run each full swarm per `pstack/skills/swarm/SKILL.md`. One gates lane. The ten live lanes from the PR's Verify, live block. The perf lane from its Verify, perf block. Two or more audit lanes, each with its own focus, that read the diff and the receipts and distrust the PR body. The root audits the receipts in the merge-ready report before the verdict.
- [ ] Judge every finding by the execution playbook's blocking rule. The verdict is clean when none blocks. A failure on trunk behavior in a lane marked `Regression lane against trunk.` is recorded against trunk and does not block the PR. A new head gets a fresh verdict, except for results that stay valid under the patch-id rule in `playbooks/shipping.md`.
- [ ] The root appends each verified PR to the stack and the operator lands the contiguous run bottom-up. No owner merges. A PR whose `git patch-id` a restack leaves unchanged keeps its verdict, per `playbooks/shipping.md`.

### Boot recipe, for every live lane

Each live lane runs on its own cloud VM at the PR head. `cursor-team-kit` is not installed in this Cursor setup, so there is no `control-ui` or `control-cli` skill on disk. Drive the browser with the Cursor IDE browser. Drive PR-1 by running the headless test and shooting the terminal.

- [ ] `git fetch origin <head-branch> && git checkout <head SHA>`.
- [ ] Install Godot 4.7.2. `addons/GodotTogether/src/scripts/GodotTogether.gd` sets `SUPPORTED_ENGINE_VERSION` to 4.7.2, and `project.godot` tags 4.7. Confirm `godot --version` prints 4.7.2. The plan host had no `godot` on `PATH` and no Godot app under `/Applications` or `~/Applications`.
- [ ] For PR-1, run `godot --headless --path . --script res://tests/run.gd` and read stdout. Save a screenshot of that terminal.
- [ ] For PR-2 through PR-7, run `godot --headless --export-release Web build/web/index.html`, then run `python3 -m http.server 8077` with `build/web` as the working directory. Open `http://127.0.0.1:8077/` in the Cursor IDE browser. Click and type only through that browser. Read the page with a snapshot.
- [ ] Save every screenshot to `/tmp/swarm-<pr-id>/worker-<n>/<slug>.png` and return the paths with the report.

## Encode the session (PR-1)

**Depends on.** None.

**Files.**

- [ ] Create `scripts/domain/level_config.gd`.
- [ ] Create `scripts/domain/session_state.gd`.
- [ ] Create `scripts/domain/session.gd`.
- [ ] Create `resources/levels/level_1.tres`, `resources/levels/level_2.tres`, and `resources/levels/level_3.tres`.
- [ ] Create `tests/run.gd` and `tests/session_test.gd`.
- [ ] Edit `project.godot` only to add the Session autoload at `res://scripts/domain/session.gd`.

**Build.**

- [ ] Add `LevelConfig` as a Resource with `level_number`, `npc_count`, `zone_ids`, and a checkout enum whose values are `SELF` and `CASHIER`.
- [ ] Add `SessionState` as a RefCounted with phase enum `START`, `LEVEL_SELECT`, `SHOPPING`, and `CHECKOUT`. Put `start_level`, `collect`, `required_complete`, `begin_checkout`, and `finish_checkout` on `SessionState` only.
- [ ] Save level 1 as 0 shoppers, zone ids `milk`, `bread`, and `apples`, checkout `SELF`. Save level 2 as 10 shoppers, those zones plus `eggs`, checkout `SELF`. Save level 3 as 20 shoppers, those zones plus `rice`, checkout `CASHIER`.
- [ ] Make `collect` return true only the first time a required zone id is collected. Make an unknown zone id return false and leave the set unchanged.
- [ ] Make `begin_checkout` stay in `SHOPPING` and return false while any required zone is missing. Make it set `CHECKOUT` and return true when the list is complete.
- [ ] Make `finish_checkout` set `LEVEL_SELECT` and clear `collected` only from `CHECKOUT`. From any other phase, leave the state unchanged and return false.
- [ ] Make `start_level` load that resource, clear `collected`, and set `SHOPPING`. A second `start_level` clears the previous set. An unknown level number leaves the phase unchanged and returns false.
- [ ] Make `tests/run.gd` load every `tests/*_test.gd`, call `test()`, and print `session ok` only when every test returns. Make `tests/session_test.gd` construct `SessionState` directly and print the lines in You see. Do not register these tests with `addons/GodotTogether/src/scripts/tests.gd`. That file is the editor plugin boot check.

**You see.**

- [ ] The headless log contains `level 1 npc 0 zones 3 checkout self`.
- [ ] The headless log contains `level 2 npc 10 zones 4 checkout self`.
- [ ] The headless log contains `level 3 npc 20 zones 5 checkout cashier`.
- [ ] The headless log contains `checkout refused`, then `checkout allowed`, then `collected 1`, then `zone rejected`, then `phase level_select`, then `collected cleared`, then `level rejected`, then `session ok`.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] `tests/session_test.gd` gains the level table, the short-list refusal, the double collect, the unknown zone, the finish transition, the cleared set, and the unknown level. Run `godot --headless --path . --script res://tests/run.gd`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.7-xhigh-fast` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Run `godot --headless --path . --script res://tests/run.gd` at trunk and at head. Trunk has no `tests/run.gd`. Record that absence and gate the head log plus the end state the therapist waits for, a session that can start level 1. Save `pr1-lane-1.png`. Pass when the head log contains `session ok` and the trunk record says the script is absent.
- [ ] Lane 2. Run the same script and read the level 1 line. Save `pr1-lane-2.png`. Pass when the log contains `level 1 npc 0 zones 3 checkout self`.
- [ ] Lane 3. Read the level 2 line from the same run. Save `pr1-lane-3.png`. Pass when the log contains `level 2 npc 10 zones 4 checkout self`.
- [ ] Lane 4. Read the level 3 line from the same run. Save `pr1-lane-4.png`. Pass when the log contains `level 3 npc 20 zones 5 checkout cashier`.
- [ ] Lane 5. Read the short-list refusal. Save `pr1-lane-5.png`. Pass when the log contains `checkout refused` before `checkout allowed`.
- [ ] Lane 6. Read the complete-list accept. Save `pr1-lane-6.png`. Pass when the log contains `checkout allowed`.
- [ ] Lane 7. Read the double-collect result. Save `pr1-lane-7.png`. Pass when the log contains `collected 1`.
- [ ] Lane 8. Read the unknown-zone result. Save `pr1-lane-8.png`. Pass when the log contains `zone rejected`.
- [ ] Lane 9. Read the phase after finish. Save `pr1-lane-9.png`. Pass when the log contains `phase level_select`.
- [ ] Lane 10. Read the second start and the bad level number. Save `pr1-lane-10.png`. Pass when the log contains `collected cleared` and `level rejected`.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Wall-clock seconds of `tests/run.gd` on the head, plus the printed `session ok` end state. Trunk has no script, so record that absence and do not compute a ratio.
- [ ] Probe. Run `godot --headless --path . --script res://tests/run.gd` at trunk and at head, interleaved. Time the head run. Both sides must produce a result, and the trunk result is the missing-script failure.
- [ ] Baseline. Record the trunk missing-script failure first.
- [ ] Rule. Fail the PR when the head run exits non-zero or takes 5 seconds or longer. Five seconds is a budget for this logic script, not a measured baseline.

**Review gate.** None. PR-1 is not review-gated.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto current trunk after the verdict, patch-id unchanged.
- [ ] The root appends this PR to the base-branch stack and the operator lands it bottom-up.

## Show start and level select (PR-2)

**Depends on.** PR-1.

**Files.**

- [ ] Create `Scenes/app/start.tscn` and `scripts/app/start.gd`.
- [ ] Create `Scenes/app/level_select.tscn` and `scripts/app/level_select.gd`.
- [ ] Create `Scenes/app/shopping_hold.tscn` and `scripts/app/shopping_hold.gd`.
- [ ] Create `export_presets.cfg` with a Web preset whose thread support is off.
- [ ] Edit `project.godot` only to set the main scene to `res://Scenes/app/start.tscn`.

**Build.**

- [ ] Put the project name `supermarket` and a button labeled `Start` on the start scene. `Start` calls `Session.go` into `LEVEL_SELECT`.
- [ ] Build the three level buttons from the three `LevelConfig` resources. Button text is `Level N`, the people count, the zone count, and either `Self checkout` or `Cashier`.
- [ ] On a level button, call `start_level` for that number, then `Session.go` into `SHOPPING`.
- [ ] Point the shopping scene path at `res://Scenes/app/shopping_hold.tscn`. The hold scene prints the level number and the checkout kind from `SessionState` and has no store geometry.
- [ ] Save the Web export preset with Compatibility already set by the project, and with thread support off, so a static file server is enough. Exclude `addons/GodotTogether/` from that preset so the editor plugin is not in the patient download.

**You see.**

- [ ] The browser shows `supermarket` and `Start`.
- [ ] After `Start`, three buttons show `0 people`, `10 people`, and `20 people`.
- [ ] Choosing level 1 shows a hold screen that reads `Level 1` and `Self checkout`.
- [ ] Choosing level 3 shows a hold screen that reads `Level 3` and `Cashier`.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] No new domain case. `tests/run.gd` still prints `session ok`. Run `godot --headless --path . --script res://tests/run.gd`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.7-xhigh-fast` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Open the exported page at trunk and at head. Trunk has no main scene and no Web export. Record that absence and gate the head title plus the end state the therapist waits for, a page that can reach level select. Save `pr2-lane-1.png`. Pass when the head page shows `supermarket` and `Start`, and the trunk record says there is no page.
- [ ] Lane 2. Click `Start`. Save `pr2-lane-2.png`. Pass when three level buttons are on screen.
- [ ] Lane 3. Read the level 1 button. Save `pr2-lane-3.png`. Pass when that button shows `0 people`, `3 zones`, and `Self checkout`.
- [ ] Lane 4. Read the level 2 button. Save `pr2-lane-4.png`. Pass when that button shows `10 people`, `4 zones`, and `Self checkout`.
- [ ] Lane 5. Read the level 3 button. Save `pr2-lane-5.png`. Pass when that button shows `20 people`, `5 zones`, and `Cashier`.
- [ ] Lane 6. Click level 1. Save `pr2-lane-6.png`. Pass when the hold screen shows `Level 1` and `Self checkout`.
- [ ] Lane 7. Reload the hold screen. Save `pr2-lane-7.png`. Pass when the page shows `supermarket` and `Start`, and does not show `Level 1`.
- [ ] Lane 8. From the start screen, click level 3. Save `pr2-lane-8.png`. Pass when the hold screen shows `Level 3` and `Cashier`.
- [ ] Lane 9. Reload after level 3. Save `pr2-lane-9.png`. Pass when the page shows `Start` and does not show `Cashier`.
- [ ] Lane 10. Set a narrow viewport about 390 pixels wide and open level select. Save `pr2-lane-10.png`. Pass when all three level buttons are visible and do not cover the title.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Headless load time of `Scenes/app/start.tscn` in milliseconds, and the browser end state of the title on screen. Trunk has no start scene. Record that absence and use the absolute budget.
- [ ] Probe. Add nothing. Time a headless load that instances `Scenes/app/start.tscn`, ticks one frame, and prints `boot_ms`. Run that at head. At trunk, record the missing scene. Interleave the two attempts.
- [ ] Baseline. Record the trunk missing-scene result first.
- [ ] Rule. Fail the PR when head `boot_ms` is 2000 or greater. That budget is the local scene load, not a claim about browser paint. The browser end state is the title in lane 1.

**Review gate.** The operator reviews before merge.

- [ ] Copy lane 2 screenshots into `docs/review/pr-2-review-level-select.png`.
- [ ] Record a 30 to 60 second video of the change on a lane VM. Save it as `docs/review/pr-2-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto the PR-1 branch after the verdict, patch-id unchanged.
- [ ] The root appends this PR to the base-branch stack and the operator lands it bottom-up.

## Walk in one store (PR-3)

**Depends on.** PR-2.

**Files.**

- [ ] Create `Scenes/store/store.tscn` and `Scenes/store/player.tscn`.
- [ ] Create `scripts/store/player.gd` and `scripts/store/frame_stats.gd`.
- [ ] Create `tests/store_smoke.gd` and `tests/frame_store.gd`.
- [ ] Edit the shopping path string in `scripts/domain/session.gd` from `Scenes/app/shopping_hold.tscn` to `Scenes/store/store.tscn`. Do not change `SessionState`.
- [ ] Delete `Scenes/app/shopping_hold.tscn` and `scripts/app/shopping_hold.gd`.

**Build.**

- [ ] Build one greybox floor, 40 by 24 meters, with wall blocks and one red pillar. Use `CharacterBody3D` for the player. Move with WASD and the arrow keys by calling `Input.is_physical_key_pressed`. Do not add an input map. `project.godot` stays closed after PR-2. Lock the camera behind and above the body. Do not add mouse look.
- [ ] Show a corner label from `frame_stats.gd` with the latest frame time in milliseconds.
- [ ] Keep Jolt as the 3D physics engine. Keep the Compatibility renderer. Do not switch to Forward+.

**You see.**

- [ ] After level 1, the page shows a floor, a player body, and a red pillar.
- [ ] Holding the rightward key moves the body to the red pillar, and the body stops at a wall.
- [ ] Level 2 and level 3 show that same floor and pillar.
- [ ] Reload shows `supermarket` and `Start`.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] `tests/store_smoke.gd` gains one case that instances `Scenes/store/store.tscn` and asserts the player node exists. `tests/run.gd` prints `session ok`. Run `godot --headless --path . --script res://tests/run.gd`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.7-xhigh-fast` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Open level 1 at trunk and at head. Trunk has no store scene. Record that and gate the head floor plus the end state the patient waits for, a body standing on the floor. Save `pr3-lane-1.png`. Pass when the head shows the floor and the player, and the trunk record says there is no store.
- [ ] Lane 2. Click the canvas, then hold the rightward key until the body reaches the red pillar. Save `pr3-lane-2.png`. Pass when the player body overlaps the red pillar.
- [ ] Lane 3. Walk the body into a wall. Save `pr3-lane-3.png`. Pass when the body is stopped against the wall and is not past it.
- [ ] Lane 4. Stand still and read the camera. Save `pr3-lane-4.png`. Pass when the player body is in the lower half of the frame and floor is visible ahead of the body.
- [ ] Lane 5. Start level 2. Save `pr3-lane-5.png`. Pass when the same red pillar and the same floor are visible.
- [ ] Lane 6. Start level 3. Save `pr3-lane-6.png`. Pass when the same red pillar and the same floor are visible.
- [ ] Lane 7. Click the canvas, then walk. Save `pr3-lane-7.png`. Pass when the body position differs from the spawn shot in lane 1.
- [ ] Lane 8. Release every key and wait one second. Save `pr3-lane-8.png`. Pass when a second shot one second later shows the same body position.
- [ ] Lane 9. Confirm the hold screen is gone. Save `pr3-lane-9.png`. Pass when the page shows the floor and does not show the hold text `Self checkout` as a full-screen label.
- [ ] Lane 10. Reload the page. Save `pr3-lane-10.png`. Pass when the page shows `supermarket` and `Start`.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Mean frame time in milliseconds over 300 frames of `Scenes/store/store.tscn` with level 1, plus the on-screen store the patient waits for. Trunk has no store. Record that absence and do not compute a ratio.
- [ ] Probe. Run `godot --headless --path . --script res://tests/frame_store.gd` at trunk and at head, interleaved. The head script prints `frame_ms`. The trunk result is the missing script.
- [ ] Baseline. Record the trunk missing-script result first.
- [ ] Rule. Fail the PR when head `frame_ms` is greater than 33. Thirty-three milliseconds is the frame time at 30 frames a second, the floor for a person walking in a session. If the greybox misses it, stop and report the number. Do not change the renderer in this PR.

**Review gate.** The operator reviews before merge.

- [ ] Copy lane 2 screenshots into `docs/review/pr-3-review-walk.png`.
- [ ] Record a 30 to 60 second video of the change on a lane VM. Save it as `docs/review/pr-3-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto the PR-2 branch after the verdict, patch-id unchanged.
- [ ] The root appends this PR to the base-branch stack and the operator lands it bottom-up.

## Collect groceries in zones (PR-4)

**Depends on.** PR-3.

**Files.**

- [ ] Create `scripts/store/grocery_zone.gd` and `scripts/store/zone_gate.gd`.
- [ ] Create `tests/zone_gate_test.gd`.
- [ ] Edit `Scenes/store/store.tscn` only to add five zone markers.

**Build.**

- [ ] Add five `Area3D` markers with ids `milk`, `bread`, `apples`, `eggs`, and `rice`, and labels `Milk`, `Bread`, `Apples`, `Eggs`, and `Rice`.
- [ ] Add `zone_gate.gd` as a pure function that keeps a zone only when its id is in the active level's `zone_ids`.
- [ ] On store ready, disable and hide every zone the gate rejects. On the player body entering an active zone, call `SessionState.collect` once.
- [ ] Show `N of M` and the item label on the first collect. A second enter of the same zone does not change N.

**You see.**

- [ ] Level 1 shows three markers. Walking through them shows `1 of 3`, then `2 of 3`, then `3 of 3`, with `Milk`, `Bread`, and `Apples`.
- [ ] Level 2 shows four markers and can reach `4 of 4`.
- [ ] Level 3 shows five markers. Level 1 does not show the eggs marker or the rice marker.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] `tests/zone_gate_test.gd` gains cases that keep three ids on level 1, four on level 2, and five on level 3. Run `godot --headless --path . --script res://tests/run.gd`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.7-xhigh-fast` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Open level 1 at trunk and at head. Trunk here means `main`, which has no store. Record that and gate three visible markers plus the counter end state. Save `pr4-lane-1.png`. Pass when the head shows three markers and the trunk record says there is no store.
- [ ] Lane 2. Walk into the milk zone. Save `pr4-lane-2.png`. Pass when the screen shows `1 of 3` and `Milk`.
- [ ] Lane 3. Leave the milk zone and walk into it again. Save `pr4-lane-3.png`. Pass when the screen still shows `1 of 3`.
- [ ] Lane 4. Walk into bread and apples. Save `pr4-lane-4.png`. Pass when the screen shows `3 of 3`.
- [ ] Lane 5. Start level 2. Save `pr4-lane-5.png`. Pass when four markers are visible.
- [ ] Lane 6. Start level 3. Save `pr4-lane-6.png`. Pass when five markers are visible.
- [ ] Lane 7. Start level 1 and look at the eggs and rice spots. Save `pr4-lane-7.png`. Pass when those two markers are absent and three markers remain.
- [ ] Lane 8. On level 1, after `1 of 3`, walk away and wait. Save `pr4-lane-8.png`. Pass when the counter stays `1 of 3`.
- [ ] Lane 9. On level 2, collect all four zones. Save `pr4-lane-9.png`. Pass when the screen shows `4 of 4`.
- [ ] Lane 10. On level 1 at `3 of 3`, keep walking. Save `pr4-lane-10.png`. Pass when the counter stays `3 of 3` and the player still moves.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Mean frame time in milliseconds over 300 frames of the store on level 3's zone set, plus the counter the patient waits for. Trunk has no zones. Record that absence and do not compute a ratio.
- [ ] Probe. Run `godot --headless --path . --script res://tests/frame_store.gd` at trunk and at head, interleaved. Head prints `frame_ms` with the five zones present.
- [ ] Baseline. Record the trunk missing-script result first.
- [ ] Rule. Fail the PR when head `frame_ms` is greater than 33. The same 30 frame floor as PR-3. Do not compute a ratio against trunk.

**Review gate.** The operator reviews before merge.

- [ ] Copy lane 4 screenshots into `docs/review/pr-4-review-zones.png`.
- [ ] Record a 30 to 60 second video of the change on a lane VM. Save it as `docs/review/pr-4-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto the PR-3 branch after the verdict, patch-id unchanged.
- [ ] The root appends this PR to the base-branch stack and the operator lands it bottom-up.

## Spawn wandering shoppers (PR-5)

**Depends on.** PR-4.

**Files.**

- [ ] Create `scripts/store/shopper.gd` and `scripts/store/shopper_spawner.gd`.
- [ ] Create `tests/frame_crowd.gd`.
- [ ] Edit `Scenes/store/store.tscn` only to add one `NavigationRegion3D` and one spawner.

**Build.**

- [ ] Bake a navigation mesh on the floor. Each shopper uses `NavigationAgent3D`, picks a random reachable point, walks there, waits, and repeats. Turn avoidance on.
- [ ] On store ready, instance `npc_count` shoppers from the active `LevelConfig`. Instance none when the count is 0. Do not count a cashier in this number.
- [ ] A shopper body must not call `collect`.

**You see.**

- [ ] Level 1 shows no shopper bodies.
- [ ] Level 2 shows 10 shopper bodies, and at least one changes position between two shots.
- [ ] Level 3 shows 20 shopper bodies. Collecting milk on level 2 still changes the counter, and a shopper crossing a zone does not.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] No new rule beyond the level table already locked in `tests/session_test.gd`. Run `godot --headless --path . --script res://tests/run.gd` and require `session ok`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.7-xhigh-fast` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Open level 1 at trunk and at head. Trunk has no shopper spawner. Record that and gate a level 1 store with zero shoppers. Save `pr5-lane-1.png`. Pass when the head shows the player and no shopper body, and the trunk record says there is no spawner.
- [ ] Lane 2. Start level 2 and count bodies. Save `pr5-lane-2.png`. Pass when 10 shopper bodies are visible besides the player.
- [ ] Lane 3. Start level 3 and count bodies. Save `pr5-lane-3.png`. Pass when 20 shopper bodies are visible besides the player.
- [ ] Lane 4. On level 2, take a second shot one second later. Save `pr5-lane-4.png`. Pass when at least one shopper body is in a different place.
- [ ] Lane 5. Watch the floor edges on level 3. Save `pr5-lane-5.png`. Pass when every shopper body is on the floor, not past the walls.
- [ ] Lane 6. On level 3, walk the player across the floor. Save `pr5-lane-6.png`. Pass when the player still reaches the far side.
- [ ] Lane 7. On level 2, walk into milk. Save `pr5-lane-7.png`. Pass when the counter shows `1 of 4` and 10 shoppers remain.
- [ ] Lane 8. Wait 10 seconds on level 2. Save `pr5-lane-8.png`. Pass when the shopper count is still 10.
- [ ] Lane 9. Reload, then start level 1. Save `pr5-lane-9.png`. Pass when no shopper body is visible.
- [ ] Lane 10. On level 2 at `0 of 4`, wait until a shopper crosses a zone marker. Save `pr5-lane-10.png`. Pass when the counter stays `0 of 4`.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Mean frame time in milliseconds over 300 frames of level 3 with 20 shoppers, plus the moving crowd the patient waits for. Trunk has no crowd. Record that absence and do not compute a ratio.
- [ ] Probe. Run `godot --headless --path . --script res://tests/frame_crowd.gd` at trunk and at head, interleaved. Head prints `frame_ms` for 20 shoppers. Trunk reports the missing script.
- [ ] Baseline. Record the trunk missing-script result first.
- [ ] Rule. Fail the PR when head `frame_ms` is greater than 33. This is the same 30 frame floor, now with the 20 shoppers the level adds. If it misses, stop and report the number. Do not switch physics in this PR unless the browser freeze in Appendix C is already in hand.

**Review gate.** The operator reviews before merge.

- [ ] Copy lane 3 screenshots into `docs/review/pr-5-review-crowd.png`.
- [ ] Record a 30 to 60 second video of the change on a lane VM. Save it as `docs/review/pr-5-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto the PR-4 branch after the verdict, patch-id unchanged.
- [ ] The root appends this PR to the base-branch stack and the operator lands it bottom-up.

## Check out and return (PR-6)

**Depends on.** PR-5.

**Files.**

- [ ] Create `scripts/store/checkout.gd` and `scripts/store/checkout_gate.gd`.
- [ ] Create `tests/checkout_gate_test.gd`.
- [ ] Edit `Scenes/store/store.tscn` only to add the self-checkout kiosk and the cashier.

**Build.**

- [ ] Add `checkout_gate.gd` as a pure function. It allows checkout only when `required_complete` is true.
- [ ] When the level checkout kind is `SELF`, show the kiosk and hide the cashier. List collected labels. Enable `Pay` only when the gate allows it. Otherwise show the remaining count and keep `Pay` disabled. `Pay` calls `begin_checkout`, then `finish_checkout`, then `Session.go` to `LEVEL_SELECT`.
- [ ] When the level checkout kind is `CASHIER`, show the cashier and hide the kiosk. The cashier is not a wandering shopper. Three presses of `Next` show `Hello`, then the item labels, then `Goodbye`. `Goodbye` calls the same finish path. If the gate refuses, `Next` does not advance and the screen shows the remaining count.
- [ ] Place both stations at the front of the store. Do not add a second exit trigger.

**You see.**

- [ ] Level 1 at `2 of 3` keeps `Pay` disabled and shows one remaining.
- [ ] Level 1 at `3 of 3` returns to the three level buttons after `Pay`.
- [ ] Level 2 has no cashier body. Level 3 has a cashier and no kiosk.
- [ ] Level 3 at `5 of 5` shows `Goodbye` and then the three level buttons. The next level 1 run starts at `0 of 3`.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] `tests/checkout_gate_test.gd` gains the refusal under a short list and the allow when the list is complete, for counts 3, 4, and 5. Run `godot --headless --path . --script res://tests/run.gd`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.7-xhigh-fast` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Open level 1 at trunk and at head. Trunk has no kiosk. Record that and gate a kiosk that refuses a short list. Save `pr6-lane-1.png`. Pass when the head shows one item remaining and the trunk record says there is no kiosk.
- [ ] Lane 2. On level 1, collect three zones and press `Pay`. Save `pr6-lane-2.png`. Pass when the three level buttons are on screen.
- [ ] Lane 3. On level 2, collect three zones and use the kiosk. Save `pr6-lane-3.png`. Pass when `Pay` is disabled and the screen shows one remaining.
- [ ] Lane 4. On level 2, collect four zones and press `Pay`. Save `pr6-lane-4.png`. Pass when the three level buttons are on screen.
- [ ] Lane 5. On level 2, look at the front of the store. Save `pr6-lane-5.png`. Pass when the kiosk is visible and no cashier body is visible.
- [ ] Lane 6. On level 3, look at the front of the store. Save `pr6-lane-6.png`. Pass when the cashier is visible and the kiosk is absent.
- [ ] Lane 7. On level 3, collect four zones and press `Next`. Save `pr6-lane-7.png`. Pass when the screen shows one remaining and does not show `Hello`.
- [ ] Lane 8. On level 3, collect five zones and press `Next` three times. Save `pr6-lane-8.png`. Pass when `Goodbye` was shown and the following screen has the three level buttons.
- [ ] Lane 9. After lane 8, start level 1. Save `pr6-lane-9.png`. Pass when the counter shows `0 of 3`.
- [ ] Lane 10. Finish level 1 with zero shoppers on screen. Save `pr6-lane-10.png`. Pass when `Pay` returns to the three level buttons.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Mean frame time in milliseconds over 300 frames of level 3 standing at the cashier, plus the level-select end state the therapist waits for. Trunk has no cashier. Record that absence and do not compute a ratio.
- [ ] Probe. Run `godot --headless --path . --script res://tests/frame_crowd.gd` at trunk and at head, interleaved. Head prints `frame_ms` with the cashier present.
- [ ] Baseline. Record the trunk missing-script result first.
- [ ] Rule. Fail the PR when head `frame_ms` is greater than 33. That is the same 30 frame budget as PR-3. The user-visible end state is the return to level select in lane 2.

**Review gate.** The operator reviews before merge.

- [ ] Copy lane 8 screenshots into `docs/review/pr-6-review-cashier.png`.
- [ ] Record a 30 to 60 second video of the change on a lane VM. Save it as `docs/review/pr-6-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto the PR-5 branch after the verdict, patch-id unchanged.
- [ ] The root appends this PR to the base-branch stack and the operator lands it bottom-up.

## Export the browser build (PR-7)

**Depends on.** PR-6.

**Files.**

- [ ] Edit `scripts/store/frame_stats.gd` only so the corner label is visible in a debug build and hidden in a release export.
- [ ] Create `tests/export_flags.gd`.

**Build.**

- [ ] Leave the Web preset on thread support off and on the Compatibility renderer.
- [ ] Make `tests/export_flags.gd` read `export_presets.cfg` and print `threads off` only when the thread-support line is false.
- [ ] Do not add accounts, a server, or a second scene per level.

**You see.**

- [ ] A static server on port 8077 serves the release export. The page shows `supermarket` and `Start`.
- [ ] Level 1, level 2, and level 3 each return to the three level buttons after a full pickup and checkout.
- [ ] The release page does not show the `frame_ms` label. A reload in the middle of a shop shows `Start`.

**Verify, unit.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] `tests/export_flags.gd` gains the thread-support case and prints `threads off`. Run `godot --headless --path . --script res://tests/run.gd`.

**Verify, live.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked. Ten lanes on `grok-4.7-xhigh-fast` at the PR head, per the boot recipe.

- [ ] Lane 1. Regression lane against trunk. Open the static page at trunk and at head. Trunk has no export. Record that and gate a full level 1 loop on the head. Save `pr7-lane-1.png`. Pass when the head returns to the three level buttons after milk, bread, apples, and `Pay`, and the trunk record says there is no export.
- [ ] Lane 2. Run a full level 2 loop on the export. Save `pr7-lane-2.png`. Pass when the page returns to the three level buttons after four zones and `Pay`.
- [ ] Lane 3. Run a full level 3 loop on the export. Save `pr7-lane-3.png`. Pass when the page returns to the three level buttons after five zones and `Goodbye`.
- [ ] Lane 4. Load the page from `python3 -m http.server` with no cross-origin isolation headers. Save `pr7-lane-4.png`. Pass when `supermarket` is visible and the page shows no thread-isolation error.
- [ ] Lane 5. Reload during level 1 after one collect. Save `pr7-lane-5.png`. Pass when the page shows `Start` and does not show `1 of 3`.
- [ ] Lane 6. Open a fresh tab to the same URL. Save `pr7-lane-6.png`. Pass when the tab shows `Start`.
- [ ] Lane 7. Start level 3 and wait one second. Save `pr7-lane-7.png`. Pass when a shopper body has moved and the release page has no `frame_ms` label.
- [ ] Lane 8. On the export, collect milk on level 1. Save `pr7-lane-8.png`. Pass when the screen shows `1 of 3` and `Milk`.
- [ ] Lane 9. On the export, open the level 1 kiosk at `1 of 3`. Save `pr7-lane-9.png`. Pass when `Pay` is disabled.
- [ ] Lane 10. Click the canvas on the export and walk to a zone. Save `pr7-lane-10.png`. Pass when the body moves only after the canvas click, then the counter can change.

**Verify, perf.** Tests alone are not sufficient verification. A PR is verified only when its unit, live, and perf boxes are all checked.

- [ ] Metric. Mean frame time in milliseconds over 300 frames of release-equivalent level 3 with 20 shoppers, plus the browser end state of a finished level 3. Trunk has no export. Record that absence and do not compute a ratio.
- [ ] Probe. Run `godot --headless --path . --script res://tests/frame_crowd.gd` at trunk and at head, interleaved. Head prints `frame_ms`. Also load the release page and confirm the title.
- [ ] Baseline. Record the trunk missing-script result first.
- [ ] Rule. Fail the PR when head `frame_ms` is greater than 33, or when the release page does not show `supermarket` within 5 seconds of the HTTP response. Five seconds is a budget for first paint on a local static server. Do not compute a ratio against trunk.

**Review gate.** The operator reviews before merge.

- [ ] Copy lane 3 screenshots into `docs/review/pr-7-review-export.png`.
- [ ] Record a 30 to 60 second video of the change on a lane VM. Save it as `docs/review/pr-7-review.mp4`.
- [ ] Post the screenshots and the video in chat. Stop at merge-ready. Wait for the operator's click.

**Merge.**

- [ ] Root's clean verdict at the exact head SHA.
- [ ] Bugbot triage done.
- [ ] Rebased onto the PR-6 branch after the verdict, patch-id unchanged.
- [ ] The root appends this PR to the base-branch stack and the operator lands it bottom-up.

## Close the program

- [ ] Every box above is checked with its evidence.
- [ ] Reply to the operator with the report the execution playbook names.

## Appendix A. Prototype evidence

No prototype branch, SHA, or screenshot exists. `command -v godot` printed nothing. No Godot app was under `/Applications` or `~/Applications`. A throwaway store could not be run on this host.

These questions stay unproven until an owner has Godot 4.7.

The one-store shape versus three copied stores was settled on paper. It is not proven inside the engine. The repo survey that locked the current files is `survey-godot.md` in this agent store. It found no main scene, no test command, no export preset, and an empty `Scenes/test.tscn`.

Jolt on a single-threaded web export with a moving `CharacterBody3D` is not proven here. The Godot 4.7 web export page says the web target uses the Compatibility renderer, and that the single-threaded export is the default because it does not need cross-origin isolation. A Jolt freeze on that single-threaded export was reported against Godot 4.5 beta 6 and fixed on master. This project tags 4.7. PR-3 is the first run that can prove the body still moves after two minutes in the browser.

Third person versus first person was not prototyped. The default is third person with the camera locked to the body. Say if you want first person, or a top-down camera, and PR-3 changes before any owner starts.

## Appendix B. Alternatives rejected

Three store scenes, one per level. A moved shelf would be edited three times, and the people counts would drift away from the test table.

One script that branches on the level number for spawning, zones, and checkout. The next intensity would add another branch in each system.

A door trigger after payment, in addition to checkout. The loop already ends the store visit at checkout. A second trigger is a second flag that can disagree with `finish_checkout`. The kiosk and the cashier stand at the front of the store, and finishing that interaction loads level select. Say if you want a separate door the patient has to walk through after payment.

First-person mouse look. Pointer lock in a browser is easy to lose when the canvas is not focused, and it is harsher to watch. The default is WASD and the arrow keys, with `Pay` and `Next` on screen.

A 2D top-down store. `project.godot` already sets the 3D physics engine to Jolt. `Scenes/test.tscn` is an empty `Node2D` with no script, so it is not a 2D decision. People at eye height are the social stimulus. The empty scene stays unused.

Accounts, saved progress, and a clinic server. The request is a page the therapist opens. A server would store session data this plan does not ask for.

GodotTogether as a runtime multiplayer layer. The addon is an editor collaboration plugin. The session is one local player.

## Appendix C. Risks

PR-1. The host has no Godot binary. The owner installs 4.7 before the first test. A wrong minor version makes the headless script a false failure.

PR-3 and PR-5. Jolt on a single-threaded web export froze in Godot 4.5 beta 6 around the 120th physics frame when a body moved. The report says the fix landed on master. The owner walks the release build for two minutes. If the browser freezes, switch the 3D physics engine to Godot Physics, record the switch, and stop. Do not keep debugging Jolt inside the feature PR.

PR-2 through PR-7. `cursor-team-kit` is not installed, so `control-ui` and `control-cli` are missing. Lanes use the Cursor IDE browser and a terminal screenshot. That is a weaker driver than the kit. The boot recipe names the actual clicks.

Arm the program. `git show origin/main:pstack/...` fails on this repo because `main` has no pstack tree. The owner reads the plugin-cache copies and records the fallback.

PR-2. Anyone who can open the page can pick level 3. There is no therapist PIN. Say if the level buttons need a code.

PR-3. Walking assumes a keyboard. There is no on-screen stick. Say if the session has to run on a tablet.

PR-3. The store art is a grey floor, grey walls, and a red pillar. The loop can be tested on that art.

PR-5. Twenty navigation agents on one web thread may miss the 33 ms budget. The perf rule stops the PR and reports the number.

All PRs. Do not edit `addons/GodotTogether/**`. Do not set `Scenes/test.tscn` as the main scene.

## Appendix D. Links and reading list

Read these before editing.

The Godot 4.7 page "Exporting for the Web", at `https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html`.

The Godot 4.7 page "Using Jolt Physics", at `https://docs.godotengine.org/en/4.7/tutorials/physics/using_jolt_physics.html`.

Godot issue 109948, the single-threaded web Jolt freeze, at `https://github.com/godotengine/godot/issues/109948`.

`project.godot` in this repo, for the 4.7 feature tag, the Compatibility renderer, and the Jolt setting.

PR-5 reads the navigation docs for `NavigationAgent3D` before baking. PR-6 reads this plan's checkout section again before adding the cashier copy. Interrogate PR-6 only if a second cashier flow is proposed. The sketch in Appendix F is the flow.

This plan file is the decision trail. Owners put evidence links in the PR body. They do not start a second log.

## Appendix E. Feature catalog

| Feature | PR | What that PR builds |
| --- | --- | --- |
| Level table and session rules | PR-1 | `LevelConfig`, `SessionState`, three resources, headless tests |
| Start screen | PR-2 | `Scenes/app/start.tscn` with `supermarket` and `Start` |
| Level select | PR-2 | Three buttons built from the resources |
| Shopping hold | PR-2 | Temporary screen so a chosen level is visible before the store exists |
| Web preset | PR-2 | `export_presets.cfg` with thread support off |
| One store and player movement | PR-3 | 40 by 24 meter greybox, `CharacterBody3D`, locked third-person camera |
| Frame time label | PR-3 | Corner label, hidden in the release export by PR-7 |
| Grocery zones | PR-4 | Five markers, auto collect on enter, `N of M` label |
| Zone gate | PR-4 | Pure function that hides zones the level does not list |
| Wandering shoppers | PR-5 | Spawner, baked nav mesh, counts 0, 10, and 20 |
| Self checkout | PR-6 | Kiosk, remaining count, `Pay`, return to level select |
| Cashier | PR-6 | Stationary cashier, `Hello`, items, `Goodbye` |
| Release browser loop | PR-7 | Static export of the full level 1, level 2, and level 3 loops |

Item labels are `Milk`, `Bread`, `Apples`, `Eggs`, and `Rice`. Level 1 uses the first three. Level 2 adds `Eggs`. Level 3 adds `Rice`. The cashier is not part of the shopper count.

## Appendix F. How the systems fit

`SessionState` owns the phase and the collected ids. `LevelConfig` owns the people count, the zone ids, and the checkout kind. The autoload `Session` is a thin node. It holds one `SessionState`, and it changes scenes. It does not decide whether a zone counts.

The store reads the active level when it is ready. Zones, the spawner, the kiosk, and the cashier ask `SessionState` what to show. They send `collect`, `begin_checkout`, and `finish_checkout` back. They do not read each other's nodes to apply a rule.

Start and level select never spawn people and never edit the collected set except by calling `start_level`. `start_level` clears that set, so a new pick cannot inherit the last run.

The phase order is `START`, then `LEVEL_SELECT`, then `SHOPPING`, then `CHECKOUT`, then `LEVEL_SELECT` again. `begin_checkout` refuses to enter `CHECKOUT` while a required zone is missing. That refusal is one function, used by the kiosk and by the cashier, so the two stations cannot disagree.

Shoppers are scenery with paths. They are not customers in the rules. The therapist changes intensity by picking a resource, not by editing the store.

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
