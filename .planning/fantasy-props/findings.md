# Findings

- Existing resource branch is clean at eb0acc0; Blender MCP remains running.
- User wants individually reusable models, animations where appropriate, and
  explicitly challenged treating fantasy as a fixed gray-green palette.
- Existing Blender MCP runner embeds the former tree prompt. Add an optional
  current request argument so the new modeling task uses the correct request.
- Flat PBR materials avoid the prior Godot vertex-color importer mismatch.
- GLB export needs use_active_scene and animation slide-to-zero. Source .blend
  folders need .gdignore. Static props should contain no accidental animation.
