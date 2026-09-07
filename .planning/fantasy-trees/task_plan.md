# Fantasy tree asset pack

- [x] Inspect reference and current art direction. User authorized a new tree pack, not broader map changes.
- [x] Build six distinct Blender trees and export GLB files at root-ground origin, meters.
- [x] Render and inspect silhouettes, foliage, trunks and alternate views.
- [x] Validate Godot imports, create reusable scenes with canopy-only wind and trunk collision.
- [x] Deliver source, models, preview and measured budgets.

## Scope
Reference-inspired storybook fantasy trees, muted sage foliage, twisting trunks,
layered irregular crowns. Six structural variants, including restrained gold and violet.
Existing map and assets stay outside this task.

## Added requirement
Each GLB includes a four-second Wind_Sway morph animation; canopy only, static trunk.
Each Godot prefab also includes seven falling particles and ten ground leaves,
with independent switches. Each tree has a separately validated editable .blend.

## Resolved issues
- glTF exporter initially included the default scene cube: use_active_scene fixes export scope.
- Godot tried importing the editable .blend: source folder now has .gdignore; runtime uses GLB.
- UV/tangent import warnings fixed with per-face projected UVs.
- Godot did not enable vertex-color albedo: asset-specific post-import script sets it;
  verified with assertions and corrected actual rendered screenshots.
- Godot capture type inference fixed by explicitly casting the loaded PackedScene.
