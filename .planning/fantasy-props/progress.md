# Progress

2026-09-07: Started 27-prop pack on existing resource branch after inspecting art
direction, clean status, Blender connection, and tree export/validation scripts.

User redirected to sequential acceptance before the batch builder was run.
Restricted current execution to first fern. Explained Blender source materials
versus Godot runtime lighting; will deliver comparable views before asking acceptance.

Blender 5.2 crashed in libraries.write on the new animated prop source, both live
and in an isolated process. GLB export succeeds. Switched source saving to a normal
save_as_mainfile in a separate background scene stripped to the single prop.

User approved moving on from first fern after discussion of animation and physics.
Working on second fiddlehead fern only, preserving the one-at-a-time review boundary.
Physics interaction remains unimplemented; mild keyed wind is the current animation.

Latest correction: user wants category-level acceptance. Expand current work to
all seven Woodland Plants, then stop for category review. Other categories remain pending.

Woodland group built: seven separate GLBs and .blend files; four closed 4-second
foliage loops; three static mushroom variants. Godot imports and prefab playback
checks pass. Inspected Blender overview and Godot front/reverse captures; lowered
preview light intensity after initial Godot view washed out bright leaf details.

Final capture completed with no runtime errors: 64 frames plus reverse view.
Seven prefab tests pass (370-1,580 triangles per model). Category-level delivery
is ready; awaiting user acceptance before creating the next category.

User accepted Woodland Plants and asked to continue. Building Natural Debris
08-12 only. Preserve all accepted models; scope plant checks to their category as
the shared manifest grows. Larger props will have static collision, small clutter none.

Initial five-prop import checks passed, including physics raycasts for all five
roles and revalidation of the accepted plant group. Viewed Blender overview;
adjusted moss coverage from isolated pads to connected top facets and tightened
the natural-debris contact sheet to three columns.

Natural Debris complete: 104-944 triangles per item, all five standalone Blender
sources saved. Final imports have no errors, five physics raycast checks passed,
and front/reverse Godot screenshots show complete geometry and intended colors.
No animation added to static debris; hollow-log collision is explicitly documented
as a convex approximation. Await category approval before Travel Items.

User rejected the first debris group as too cartoon-like and approved a substantial
revision. New dedicated builder uses coherent irregular geometry, fractured boulders,
torn hollow wood, and baked 1024px albedo/normal/roughness per item. Initial bake
completed; exporter tangent warnings on end caps addressed by triangulating before
UV baking. Prior accepted plants remain untouched.

Viewed first textured revision. Geometry/material direction is substantially less
regular, but wood rim had too many repeated teeth; reduced high-frequency rim
variation to a few larger tears and splinters. Added small unevenness to fracture
surfaces. Legacy builder defaults back to Plants so it cannot overwrite revised debris.

Revision 2 finished: all five independent sources exported, embedded PBR maps
validated in Godot, and five physics raycast checks passed. Front and reverse
Godot captures inspected successfully. Updated README with final triangle counts
and texture/source paths. Awaiting Natural Debris category acceptance; no push.

User accepted Natural Debris revision 2 and requested the next category. Travel
Items 13-16 completed with embedded 1024px PBR texture atlases and independent
Blender/GLB/prefab files. Backpack 18192 triangles, bedroll 5164, lantern 1168,
flask 2696. Corrected overlapping roll-end details and angular flask strap after
viewing the first Godot captures; reduced lantern emission to preserve detail.
Four imports/material checks and the closed four-second lantern animation passed.
Verified runtime lantern defaults static/lit and supports hanging/unlit instances.
Final Godot front/reverse captures and Blender render inspected. This category
awaits user acceptance; Village Items not started. No commit or push this turn.

User accepted Travel Items and requested Village Items, then explicitly steered
the active category toward more realism. Completed five standalone GLB/Blender/
prefab assets, baked surface maps, woven basket, split firewood, fitted barrel
hoops and thick-walled pottery. Reduced excessive ceramic mottling after closeup
inspection; repaired handle joins and barrel hoop intersections. Final counts:
17=7104, 18=24720, 19=10860, 20=6592, 21=6592 triangles. All five material/import
and physics raycast checks passed. Three static convex blockers and two decorations;
no animation, rigidbody, breaking or pickup behavior. Final front/reverse Godot
captures and five closeups available. Await Village category acceptance; no push.
