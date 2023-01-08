#include "Vec3f.as"

shared interface IPhysics
{
	Vec3f getPosition();
	void SetPosition(Vec3f position);

	Vec3f getVelocity();
	void SetVelocity(Vec3f velocity);
}
