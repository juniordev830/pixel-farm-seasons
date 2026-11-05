# Camera design decision: GTA-style third person

Approved gameplay direction:
- Camera remains behind the farmer outdoors and indoors.
- Mouse controls camera orbit; movement follows camera direction.
- SpringArm3D shortens camera distance near walls.
- Character mesh turns toward movement; the camera never switches to an overhead or fixed room view.
- Future Android build: virtual joystick and touch camera orbit.
- Future quality pass: character rig, walk/run/idle animations, shoulder offset and camera damping.

Validation checklist:
1. Rotate camera 360 degrees outdoors.
2. Walk through the farmhouse entrance.
3. Stand near walls; verify the camera does not pass through them.
4. Walk backwards and sideways; verify the farmer mesh turns independently.
5. Open and close the front door with E; ensure camera ray reaches the door.
6. Test with controller and touch controls when implemented.

This is a design decision and an implementation prototype, not evidence of a successful Godot runtime test.
