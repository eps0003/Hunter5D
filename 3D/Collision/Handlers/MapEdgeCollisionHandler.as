#include "ICollisionHandler.as"

shared class MapEdgeCollisionHandler : ICollisionHandler
{
	private IPhysics@ entity;
	private Vec3f mapDim;

	MapEdgeCollisionHandler(IPhysics@ entity)
	{
		@this.entity = entity;
		mapDim = Map::getMap().dimensions;
	}

	bool handleCollision()
	{
		bool collided = false;

		AABB@ collider = entity.getCollider();
		if (collider !is null)
		{
			Vec3f position = entity.getPosition();
			Vec3f velocity = entity.getVelocity();
			Vec3f nextPos = position + velocity;

			// X-axis
			if (velocity.x < 0.0f && nextPos.x + collider.min.x < 0.0f)
			{
				position.x = -collider.min.x;
				velocity.x = 0.0f;
				collided = true;
			}
			else if (velocity.x > 0.0f && nextPos.x + collider.max.x > mapDim.x)
			{
				position.x = mapDim.x - collider.max.x - 0.0001f;
				velocity.x = 0.0f;
				collided = true;
			}

			// Z-axis
			if (velocity.z < 0.0f && nextPos.z + collider.min.z < 0.0f)
			{
				position.z = -collider.min.z;
				velocity.z = 0.0f;
				collided = true;
			}
			else if (velocity.z > 0.0f && nextPos.z + collider.max.z > mapDim.z)
			{
				position.z = mapDim.z - collider.max.z - 0.0001f;
				velocity.z = 0.0f;
				collided = true;
			}

			entity.SetPosition(position);
			entity.SetVelocity(velocity);
		}

		return collided;
	}

	bool isOnGround()
	{
		return false;
	}
}
