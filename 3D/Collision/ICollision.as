#include "IPhysics.as"
#include "AABB.as"
#include "CollisionFlag.as"

shared interface ICollision : IPhysics
{
	AABB@ getCollider();
}