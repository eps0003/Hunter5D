#include "ICollision.as"

shared interface ICollisionHandler
{
	bool handleCollision();
	bool isOnGround();
}
