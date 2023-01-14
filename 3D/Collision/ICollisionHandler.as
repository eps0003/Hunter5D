#include "IPhysics.as"

shared interface ICollisionHandler
{
	bool handleCollision();
	bool isOnGround();
}
