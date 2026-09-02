# Phase 0 Scalable Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the current single-map prototype into a saveable, data-driven foundation that can support the 60–90 minute prologue without changing Fog Valley's accepted visuals or controls.

**Architecture:** Keep the current Fog Valley scene as the only playable region while introducing a serializable `WorldState`, thin Autoload services, data-driven quest/dialogue resources, a reusable interaction contract, and a region router. Extract runtime responsibilities from `scripts/main.gd` behind focused controllers only after behavior is protected by tests; deterministic visual construction remains intact during this phase.

**Tech Stack:** Godot 4.7.1, typed GDScript, `.tscn` scenes, `.tres` resources, JSON save files, existing `SceneTree` script tests.

**Spec:** `docs/game-design-bible.md` (sections 18, 21, 25–28) and `docs/game-production-decision-report.md` (sections 4–6)

## Global Constraints

- Target Windows PC first; keyboard/mouse and controller-ready input architecture.
- Preserve the current `res://scenes/main.tscn` launch path until the final integration task.
- Preserve player movement, camera, Fog Valley composition, time, weather, NPC routines, roof avoidance and all current interaction text unless a task explicitly migrates that behavior.
- Use typed GDScript. Do not infer types from `Dictionary.get()` or mixed-type expressions.
- Use direct signals for parent/child communication and the global event bus only for cross-system events.
- Store editable game data in `.tres`; store player progress in versioned JSON under `user://`.
- Do not add combat, inventory, new regions or new story content in this plan.
- Run Godot import before tests after pulling new binary assets.
- Implementation begins in an isolated `codex/` worktree or branch; never implement directly on a dirty `main`.

---

## Planned File Structure

```text
scripts/
  core/
    event_bus.gd               # Cross-system high-level signals only
    game_state.gd              # Owns the active WorldState
    scene_router.gd            # Region transitions and spawn resolution
  state/
    world_state.gd             # Serializable authoritative progress model
  save/
    save_service.gd            # Atomic JSON read/write and version checks
  quests/
    quest_data.gd              # Authored quest definition
    quest_step_data.gd         # Authored step definition
    quest_runtime.gd           # Applies quest transitions to WorldState
  dialogue/
    dialogue_data.gd           # Authored conversation definition
    dialogue_line_data.gd      # One line plus conditions/effects
    dialogue_runner.gd         # Emits dialogue presentation events
  interaction/
    interaction_target.gd      # Reusable world interaction contract
  world/
    fog_valley_runtime.gd      # Fog Valley orchestration after extraction
    time_weather_controller.gd # Time/weather sampling and application
    villager_controller.gd     # NPC schedules and proximity behavior
    ecosystem_controller.gd    # Wind, leaves, insects and pond motion
scenes/
  game/game_root.tscn          # Persistent shell and region container
  world/fog_valley.tscn        # Region wrapper around accepted map
data/
  quests/prologue_arrival.tres
  dialogue/fog_valley_intro.tres
tools/run_game.ps1
tests/
  world_state_test.gd
  save_service_test.gd
  quest_runtime_test.gd
  dialogue_runner_test.gd
  interaction_target_test.gd
  scene_router_test.gd
  fog_valley_refactor_test.gd
```

## Task 1: Reproducible Import and Baseline Gate

**Files:**
- Create: `tools/run_game.ps1`
- Create: `tests/fog_valley_baseline_test.gd`
- Create: `.gitattributes`

**Interfaces:**
- Consumes: Godot executable path supplied as `-GodotPath`.
- Produces: one command that imports assets, runs the baseline test, and launches the game only after both succeed.

- [ ] **Step 1: Write the failing baseline test**

Create `tests/fog_valley_baseline_test.gd` as a `SceneTree` script. Load `res://scenes/main.tscn`, add it to `root`, await two frames, then assert `Player`, `PortalRuin`, `VillageHearth`, `MistPass`, three villagers, active `Camera3D`, `WorldEnvironment`, `Sun`, `rain_field`, `meadow_grass`, 16 tree canopies and 12 falling leaves. Print `FOG VALLEY BASELINE PASSED` and `quit(0)`.

- [ ] **Step 2: Run it before adding the launcher**

Run:

```powershell
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/fog_valley_baseline_test.gd
```

Expected: the scene contract passes on the current imported checkout. Temporarily rename one required node in a disposable test instance and confirm the associated assertion fails, then discard that test-only mutation.

- [ ] **Step 3: Add the import-safe launcher**

Implement `tools/run_game.ps1` with this contract:

```powershell
param([string]$GodotPath = 'D:\Godot\Godot_v4.7.1-stable_win64.exe')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
& $GodotPath --headless --path $projectRoot --import
if ($LASTEXITCODE -ne 0) { throw 'Godot asset import failed.' }
& $GodotPath --headless --path $projectRoot --script res://tests/fog_valley_baseline_test.gd
if ($LASTEXITCODE -ne 0) { throw 'Fog Valley baseline failed.' }
Start-Process -FilePath $GodotPath -ArgumentList @('--path', $projectRoot) -WorkingDirectory $projectRoot
```

Add `.gitattributes` rules `*.gd text eol=lf`, `*.tscn text eol=lf`, `*.tres text eol=lf`, `*.import text eol=lf` so Godot import does not create line-ending-only changes.

- [ ] **Step 4: Verify clean launch**

Run `powershell -ExecutionPolicy Bypass -File tools/run_game.ps1`. Expected: import exit 0, `FOG VALLEY BASELINE PASSED`, visible non-blank game window, and no source changes except the files in this task.

- [ ] **Step 5: Commit**

```powershell
git add .gitattributes tools/run_game.ps1 tests/fog_valley_baseline_test.gd
git commit -m "chore: add reproducible Godot launch gate"
```

## Task 2: Authoritative World State and Event Bus

**Files:**
- Create: `scripts/state/world_state.gd`
- Create: `scripts/core/game_state.gd`
- Create: `scripts/core/event_bus.gd`
- Create: `tests/world_state_test.gd`
- Modify: `project.godot`

**Interfaces:**
- Produces: `WorldState.to_dictionary() -> Dictionary`, `WorldState.from_dictionary(data: Dictionary) -> WorldState`, `GameState.start_new_game()`, `GameState.set_flag(key: StringName, value: Variant)`, and `EventBus.world_flag_changed(key: StringName, value: Variant)`.

- [ ] **Step 1: Write a failing round-trip test**

The test creates a `WorldState`, sets `current_region = &"fog_valley"`, `spawn_id = &"portal_arrival"`, one world flag, one relationship value and one quest state. Serialize and deserialize it; assert all values survive and modifying the copy does not mutate the original dictionaries.

- [ ] **Step 2: Verify failure**

Run the test with the standard headless command. Expected: failure because `WorldState` does not exist.

- [ ] **Step 3: Implement the minimal state resource**

Use the exact public fields:

```gdscript
class_name WorldState
extends Resource

const CURRENT_VERSION := 1
var version: int = CURRENT_VERSION
var current_region: StringName = &"fog_valley"
var spawn_id: StringName = &"portal_arrival"
var flags: Dictionary = {}
var quests: Dictionary = {}
var relationships: Dictionary = {}
var collected_ids: Array[StringName] = []
```

`to_dictionary()` must convert `StringName` values to strings. `from_dictionary()` rejects a missing/non-integer version and deep-copies dictionaries/arrays.

- [ ] **Step 4: Add thin Autoload owners**

`GameState` owns exactly one `active: WorldState`, resets it on `start_new_game()`, and emits through `EventBus` only when a value actually changes. Register `/root/EventBus` before `/root/GameState` in `project.godot`.

- [ ] **Step 5: Run tests and current smoke test**

Expected: `WORLD STATE TEST PASSED` and existing `SMOKE TEST PASSED`.

- [ ] **Step 6: Commit**

```powershell
git add project.godot scripts/core scripts/state tests/world_state_test.gd
git commit -m "feat: add authoritative world state"
```

## Task 3: Versioned Atomic Save Service

**Files:**
- Create: `scripts/save/save_service.gd`
- Create: `tests/save_service_test.gd`
- Modify: `project.godot`

**Interfaces:**
- Consumes: `WorldState.to_dictionary()` and `WorldState.from_dictionary()`.
- Produces: `save_state(state: WorldState, path: String) -> Error`, `load_state(path: String) -> WorldState`, `has_valid_save(path: String) -> bool`.

- [ ] **Step 1: Write failing save tests**

Use `user://tests/phase0-save.json`. Cover round-trip, nonexistent file, invalid JSON, unsupported future version, and preservation of the previous valid file when a write fails. Delete only this exact test path during test cleanup.

- [ ] **Step 2: Verify failure**

Expected: failure because `SaveService` does not exist.

- [ ] **Step 3: Implement atomic writes**

Write JSON to `<path>.tmp`, flush and close it, rename the current final file to `<path>.bak` when present, then rename the temporary file to the final path. If the second rename fails, restore the backup to the final path. On parse/version failure, return `null` and emit `save_failed(path, reason)` without modifying `GameState.active`.

- [ ] **Step 4: Register Autoload and verify**

Register `/root/SaveService`. Run save tests twice to prove cleanup and repeatability, then run `tests/smoke_test.gd`.

- [ ] **Step 5: Commit**

```powershell
git add project.godot scripts/save/save_service.gd tests/save_service_test.gd
git commit -m "feat: add versioned atomic saves"
```

## Task 4: Data-Driven Quest Runtime

**Files:**
- Create: `scripts/quests/quest_step_data.gd`
- Create: `scripts/quests/quest_data.gd`
- Create: `scripts/quests/quest_runtime.gd`
- Create: `data/quests/prologue_arrival.tres`
- Create: `tests/quest_runtime_test.gd`

**Interfaces:**
- Produces: `start_quest(quest: QuestData) -> bool`, `advance(quest_id: StringName, event_id: StringName) -> bool`, `get_status(quest_id: StringName) -> StringName`.
- Quest states stored in `WorldState.quests` as `{ "status": String, "step_index": int }`.

- [ ] **Step 1: Write failing transition tests**

Define a three-step fixture using events `portal_inspected`, `toren_met`, `hearth_reached`. Assert start is idempotent, wrong events do nothing, correct events advance once, completion is stable, and serialized state resumes at the same step.

- [ ] **Step 2: Verify failure**

Expected: missing quest classes.

- [ ] **Step 3: Implement quest resources**

`QuestStepData` fields: `id: StringName`, `description_key: StringName`, `required_event: StringName`. `QuestData` fields: `id`, `title_key`, `steps: Array[QuestStepData]`. Reject empty IDs and duplicate step IDs in `_get_configuration_warnings()`.

- [ ] **Step 4: Implement runtime and first authored quest**

`QuestRuntime` receives `WorldState` through `configure(state: WorldState)`. It emits `quest_started`, `quest_advanced`, `quest_completed` and forwards only those high-level events to `EventBus`. Create `prologue_arrival.tres` with the three exact fixture events; do not yet change live Fog Valley interactions.

- [ ] **Step 5: Verify and commit**

Run quest, world-state, save and smoke tests. Commit:

```powershell
git add scripts/quests data/quests tests/quest_runtime_test.gd
git commit -m "feat: add data-driven quest runtime"
```

## Task 5: Dialogue Runner and Reusable Interaction Target

**Files:**
- Create: `scripts/dialogue/dialogue_line_data.gd`
- Create: `scripts/dialogue/dialogue_data.gd`
- Create: `scripts/dialogue/dialogue_runner.gd`
- Create: `scripts/interaction/interaction_target.gd`
- Create: `data/dialogue/fog_valley_intro.tres`
- Create: `tests/dialogue_runner_test.gd`
- Create: `tests/interaction_target_test.gd`

**Interfaces:**
- Consumes: `WorldState.flags` for conditions/effects and the actor position for proximity checks.
- Produces: the following two public contracts.
- `InteractionTarget`: signal `interacted(target_id: StringName)`, fields `target_id`, `prompt_key`, `priority`, method `can_interact(actor: Node3D) -> bool`.
- `DialogueRunner`: signals `line_started(speaker_id, text_key)`, `choice_requested(choice_ids)`, `dialogue_finished(dialogue_id)`; methods `start(data, context)`, `advance()`, `choose(choice_id)`.

- [ ] **Step 1: Write failing dialogue tests**

Cover linear two-line playback, a conditionally hidden line, two choices, one flag effect, invalid choice rejection, and finishing exactly once.

- [ ] **Step 2: Write failing interaction tests**

Create two targets at different distances/priorities. Assert disabled targets are ignored, higher priority wins within equal range, and `interacted` emits once per accepted input.

- [ ] **Step 3: Implement typed resources and runners**

Dialogue lines contain IDs/keys, not translated prose in code. Conditions are limited to `required_flags` and `blocked_flags`; effects are limited to `set_flags` and `emit_event_ids` for Phase 0. Do not implement scripting expressions.

- [ ] **Step 4: Author the intro fixture**

Create a short data resource containing the current portal, Mira, Toren and Nia lines as migration fixtures. It must preserve existing displayed Chinese text through localization keys or a temporary string table, without expanding the story.

- [ ] **Step 5: Verify and commit**

Run the two new tests plus state/save/quest/smoke tests. Commit:

```powershell
git add scripts/dialogue scripts/interaction data/dialogue tests/dialogue_runner_test.gd tests/interaction_target_test.gd
git commit -m "feat: add dialogue and interaction contracts"
```

## Task 6: Region Router and Persistent Game Root

**Files:**
- Create: `scripts/core/scene_router.gd`
- Create: `scenes/game/game_root.tscn`
- Create: `scenes/world/fog_valley.tscn`
- Create: `tests/scene_router_test.gd`
- Modify: `project.godot`

**Interfaces:**
- Produces: `travel_to(region_id: StringName, spawn_id: StringName) -> Error`, signal `region_changed(region_id)`, group contract `region_spawn:<spawn_id>`.

- [ ] **Step 1: Write failing router tests**

Use two minimal in-memory packed scenes. Assert the router rejects an unknown region, loads a known region, moves the player to the named spawn, updates `WorldState.current_region/spawn_id`, frees the previous region only after the new one instantiates, and never emits `region_changed` on failure.

- [ ] **Step 2: Verify failure**

Expected: `SceneRouter` missing.

- [ ] **Step 3: Implement the persistent shell**

`game_root.tscn` owns `RegionContainer`, `PersistentUI`, `DialogueRunner` and `QuestRuntime`. `SceneRouter` uses a fixed Phase 0 registry `{ &"fog_valley": preload("res://scenes/world/fog_valley.tscn") }`; do not add generic filesystem discovery.

- [ ] **Step 4: Wrap Fog Valley without changing visuals**

Instance the existing `main.tscn` under `fog_valley.tscn`, add spawn markers for `portal_arrival` and `mist_pass_return`, then set `run/main_scene` to `game_root.tscn`. Maintain a compatibility path so `tests/smoke_test.gd` can still instantiate `main.tscn` directly.

- [ ] **Step 5: Verify and commit**

Run router tests, the complete Phase 0 test set and the visual baseline. Launch the visible game and compare portal arrival against the current accepted view. Commit:

```powershell
git add project.godot scripts/core/scene_router.gd scenes/game scenes/world/fog_valley.tscn tests/scene_router_test.gd
git commit -m "feat: add persistent game root and region routing"
```

## Task 7: Extract Fog Valley Runtime Controllers

**Files:**
- Create: `scripts/world/time_weather_controller.gd`
- Create: `scripts/world/villager_controller.gd`
- Create: `scripts/world/ecosystem_controller.gd`
- Create: `scripts/world/fog_valley_runtime.gd`
- Create: `tests/fog_valley_refactor_test.gd`
- Modify: `scripts/main.gd:175-846`
- Modify: `scenes/main.tscn`

**Interfaces:**
- Consumes: the existing nodes/material arrays built by `scripts/main.gd` and the current player reference.
- Produces: focused controllers with the exact contracts below; later tasks call controllers rather than private methods on `main.gd`.
- `TimeWeatherController.configure(context: Dictionary)`, `set_time(hour: float, running: bool)`, `set_weather_override(state: StringName)`.
- `VillagerController.configure(player: CharacterBody3D, villagers: Array[CharacterBody3D])`, signal `nearby_villager_changed(villager)`.
- `EcosystemController.configure(context: Dictionary)`, `tick(delta: float, time_hour: float, weather: Dictionary)`.
- `FogValleyRuntime` owns controller wiring and exposes compatibility getters needed by existing tests.

- [ ] **Step 1: Write the characterization test before moving code**

Record current deterministic outputs for time samples at 0.0/9.5/12.0/19.5, weather schedule seed `20260902`, portal proximity, three villager identities/routes, canopy/leaf counts, pond ripple count, and roof fade decisions at the existing test positions.

- [ ] **Step 2: Run and save the passing baseline output**

Expected: `FOG VALLEY REFACTOR BASELINE PASSED` on unmodified production code. This is a characterization test, so it passes before extraction and must remain unchanged during the task.

- [ ] **Step 3: Extract one controller at a time**

Move time/weather functions (`_apply_time_of_day` through `_animate_weather`) first, run tests; move villager runtime functions (`_update_toren_watch`, `_update_nia_routine`, `_update_villager_interaction`) second, run tests; move ecosystem animation functions third, run tests. Do not combine these moves into one unverified edit.

- [ ] **Step 4: Add the Fog Valley orchestrator**

`FogValleyRuntime` creates/configures controllers after existing deterministic construction finishes. `main.gd` retains visual builder functions in Phase 0 but delegates runtime ticks. Target: no quest/save/router dependency inside visual builder methods.

- [ ] **Step 5: Verify visual and behavioral parity**

Run `fog_valley_refactor_test.gd`, `smoke_test.gd`, the three current character tests, tree motion, tree occlusion, roof motion, and the 21-camera capture sweep. Expected: identical contractual values and no P0/P1 visual regression.

- [ ] **Step 6: Commit**

```powershell
git add scripts/main.gd scripts/world scenes/main.tscn tests/fog_valley_refactor_test.gd
git commit -m "refactor: split Fog Valley runtime controllers"
```

## Task 8: Integrate Current Interactions with State, Quest and Dialogue

**Files:**
- Modify: `scripts/main.gd:493-566`
- Modify: `scenes/main.tscn`
- Modify: `scenes/world/fog_valley.tscn`
- Modify: `data/quests/prologue_arrival.tres`
- Modify: `data/dialogue/fog_valley_intro.tres`
- Create: `tests/prologue_foundation_integration_test.gd`
- Modify: `tests/smoke_test.gd`

**Interfaces:**
- Consumes: `InteractionTarget`, `DialogueRunner`, `QuestRuntime`, `GameState.active`.
- Produces: events `portal_inspected`, `toren_met`, `mira_met`, `nia_met`, `hearth_reached` while preserving current visible prompts and lines.

- [ ] **Step 1: Write the failing integration test**

Start a new game, instantiate `game_root.tscn`, travel to Fog Valley, interact with portal and each villager, save, reload and re-enter the region. Assert each event advances at most once, dialogue survives region reload, the quest step persists, and all current interaction targets remain usable.

- [ ] **Step 2: Verify failure**

Expected: current hard-coded `_show_villager_dialogue()` and `_show_portal_lore()` do not update the new state.

- [ ] **Step 3: Replace hard-coded dispatch only**

Add `InteractionTarget` children to the portal and villagers. Route accepted interaction through `DialogueRunner` and emit the exact quest events. Keep the current bottom prompt presentation as the temporary dialogue view; do not design the final journal UI in this task.

- [ ] **Step 4: Run full Phase 0 gate**

Run, in order:

```powershell
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --import
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/world_state_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/save_service_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/quest_runtime_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/dialogue_runner_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/interaction_target_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/scene_router_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/fog_valley_refactor_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/prologue_foundation_integration_test.gd
& 'D:\Godot\Godot_v4.7.1-stable_win64.exe' --headless --path . --script res://tests/smoke_test.gd
git diff --check
```

Expected: every test prints its named `PASSED` line, all commands exit 0, and visible play starts at the same portal composition.

- [ ] **Step 5: Update architecture notes and commit**

Document the final node/service ownership in `docs/game-design-bible.md` section 18 and append measured test/runtime results to `progress.md`.

```powershell
git add scripts scenes data tests project.godot docs/game-design-bible.md progress.md
git commit -m "refactor: connect Fog Valley to scalable game foundation"
```

## Completion Gate

Phase 0 is complete only when:

- A fresh checkout can import and launch through `tools/run_game.ps1` without a blank window.
- New game state round-trips through JSON and corrupt saves do not replace valid state.
- The authored prologue quest advances through real portal/NPC interactions and survives region reload.
- `game_root.tscn` can unload/reload Fog Valley at a named spawn.
- Current visuals, controls, NPC routines, time/weather, ecosystem and roof behavior pass existing regression tests and visible review.
- No combat, inventory, additional region or new narrative branch has leaked into Phase 0.
