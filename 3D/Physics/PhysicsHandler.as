#include "IPhysicsHandler.as"

shared class PhysicsHandler : IPhysicsHandler
{
	void Update(IPhysics@ entity)
	{
		Vec3f velocity = entity.getVelocity();

		// Apply gravity
		velocity += entity.getGravity();

		// Set velocity to zero if low enough
		if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
		if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
		if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

		entity.SetVelocity(velocity);

		// Handle collision
		ICollisionHandler@ collisionHandler = entity.getCollisionHandler();
		if (collisionHandler !is null)
		{
			collisionHandler.handleCollision();
		}

		// Apply velocity
		entity.SetPosition(entity.getPosition() + entity.getVelocity());
	}
}
