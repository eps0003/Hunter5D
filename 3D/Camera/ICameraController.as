#include "Vec3f.as"

shared interface ICameraController
{
	Vec3f getCameraPosition();
	Vec3f getCameraRotation();
}
