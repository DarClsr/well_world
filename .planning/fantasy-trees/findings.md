# Findings

- docs/art-direction.md is the current authority. Natural forms use clear grouped
  crowns and twisted trunks. Canopy motion must not bend the trunk.
- Current Godot renderer is Compatibility. Existing tree shader expects a leaf
  texture, so this pack needs a small vertex-color canopy material instead.
- Blender 5.2.1 LTS and blender-mcp 1.9.1 are installed. Live Blender PID 45564.
- Reference: broad asymmetric green canopy, strong dark interior, brighter upper
  foliage, visible spreading branches, flared roots. Ground vignette is presentation,
  not part of each reusable tree.

- User questioned gray-green. Existing art direction informed the initial muted
  pass, but the supplied reference has brighter yellow-green tops and teal shadows.
  Main elder and umbrella revised toward the supplied reference; muted colors stay
  on distinct variants. Six individual editable .blend files explicitly requested.
- glTF timestamps started at frame 1 (0.033s); exporter slide-to-zero is necessary
  for a true 0-4 second loop without an initial hold.
