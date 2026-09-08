# Progress

Read scene placements and materials from v07 in Blender. No character work resumed.

Implemented shared earthen house, open shelter and timber bridge collections; three libraries saved.
Blender 5.2 partial-write crashed on a new scene; switched independent asset output to collection libraries.
Sky API changed: MULTIPLE_SCATTERING and aerosol_density are current identifiers, inspected RNA before correction.
Corrected front doorway post and roof winding before final render.

First sky render too cyan/bright; reduced sky strength to .075 and saturation to .45.
Moved existing courtyard vessels/log piles outside houses and added foot-worn earth vertex color.
Closeups identified floating bridge pile tips and overly wide reed strips; rebuilt six piles to ground minus .35m and increased finer reed detail with round ridge bundles.

Final settlement, house and bridge renders visually inspected. Matched comparison saved as before_after_v08.png.
Reopen verification passed: terrain coordinates and source v07 preserved, 5 architecture instances, 32 deck planks with matching endpoint heights, 6 piles embedded .35m.
Three standalone collection libraries append successfully with valid geometry/materials. git diff --check passed.
Completed this Blender visual polish iteration; runtime Godot work remains a separate TODO.
