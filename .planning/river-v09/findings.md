# Findings

Latest map is v08; main Godot scene remains older game_root with GL Compatibility renderer.
Map Water_Creek is a long ribbon. v08 gives static wave normals but no transparent shallows or real animation.
Need a separate river review scene rather than claiming the new map is integrated into the old gameplay.
Keep original files. Reuse bridge and rock sources. Encode geometric depth in water vertex color to support existing Compatibility renderer without screen-depth dependency.

Latest user instruction overrides the engine review plan: optimize Blender only, no Godot scene/export/shader work.
