# Prologue map development

User steering: plan delivered, user now authorizes Blender modeling with reusable assets.
Current deliverable: docs/prologue-map-development-plan.md.

- [x] Inspect Blender/Godot tools and current project conventions.
- [x] Confirm previously launched Blender process ended; retain unreviewed draft.
- [x] Write development stages, artifact layout, scope and acceptance criteria.
- [x] Validate plan links and status against existing artifacts.

Production status:
- [ ] A: review layout and elevation sketch.
- [ ] B: create/revise five terrain areas; existing auto-generated draft is not accepted.
- [ ] C: independent Godot import, camera, collision and walkability inspection.
- [ ] D: ruins and settlement modules.
- [ ] E: natural environment assets and assembly.
- [ ] F: lighting, motion and integrated performance/visual review.

Preserve existing scene entry, assets and dirty files. No commit or push.

Current: v02 Blender blockout with 8 source modules and 130 linked instances.
Overview and closeup reviewed; saved-file mesh sharing verified after reopening.
User acceptance and Godot verification pending; do not mark B fully accepted yet.

v03 dressing pass completed using 17 pre-existing independent asset sources and
959 linked collection instances. Four rendered views inspected. Saved-file check
verified source hashes, library/texture resolution and six animated source types.
Buildings remain placeholders; E is in progress, not finally accepted.

v04: eight independent ruin modules and 25 library-linked instances completed.
Standalone source/GLB and saved-map checks passed; user art acceptance pending.
Settlement still placeholder. No new commit/push requested this turn.

v05 optimization: v2 sources preserve v04 files; varied masonry and broken-wall
profiles, staggered paving, collapse debris and 10 reused edge props. Eight sources,
28 ruin instances; source, GLB texture/COLOR_0 and old-file checks passed. User visual
acceptance remains pending, as does Godot validation.
