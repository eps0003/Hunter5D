#include "ISerializable.as"
#include "ICollisionHandler.as"
#include "Vec3f.as"

shared interface IPhysics : ISerializable
{
	Vec3f getPosition();
	void SetPosition(Vec3f position);

	Vec3f getVelocity();
	void SetVelocity(Vec3f velocity);

	Vec3f getGravity();
	void SetGravity(Vec3f gravity);

	AABB@ getCollider();
	void SetCollider(AABB@ collider);

	ICollisionHandler@ getCollisionHandler();
	void SetCollisionHandler(ICollisionHandler@ handler);
}
