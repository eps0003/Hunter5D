#include "ICollisionHandler.as"
#include "Map.as"

shared class BlockCollisionHandler : ICollisionHandler
{
	private IPhysics@ entity;
	private Map@ map;

	BlockCollisionHandler(IPhysics@ entity)
	{
		@this.entity = entity;
		@map = Map::getMap();
	}

	// X-axis is tested twice to allow walking around corners with a gap below
	bool handleCollision()
	{
		bool collided = false;

		AABB@ collider = entity.getCollider();
		if (collider !is null)
		{
			Vec3f position = entity.getPosition();
			Vec3f velocity = entity.getVelocity();

			bool collidedX = false;

			// X-axis (first attempt)
			Vec3f nextPosX = position + Vec3f(velocity.x, 0, 0);
			if (velocity.x != 0 && enteringBlock(collider, position, nextPosX))
			{
				collidedX = true;
			}
			else
			{
				position.x += velocity.x;
			}

			// Z-axis
			Vec3f nextPosZ = position + Vec3f(0, 0, velocity.z);
			if (velocity.z != 0 && enteringBlock(collider, position, nextPosZ))
			{
				if (velocity.z < 0)
				{
					position.z = Maths::Floor(position.z + collider.min.z) - collider.min.z + 0.0001f;
				}
				else
				{
					position.z = Maths::Ceil(position.z + collider.max.z) - collider.max.z - 0.0001f;
				}

				velocity.z = 0;
				collided = true;
			}
			else
			{
				position.z += velocity.z;
			}

			// X-axis (second attempt if first collided)
			if (collidedX)
			{
				Vec3f nextPosX = position + Vec3f(velocity.x, 0, 0);
				if (velocity.x != 0 && enteringBlock(collider, position, nextPosX))
				{
					if (velocity.x < 0)
					{
						position.x = Maths::Floor(position.x + collider.min.x) - collider.min.x + 0.0001f;
					}
					else
					{
						position.x = Maths::Ceil(position.x + collider.max.x) - collider.max.x - 0.0001f;
					}

					velocity.x = 0;
					collided = true;
				}
				else
				{
					position.x += velocity.x;
				}
			}

			// Y-axis
			Vec3f nextPosY = position + Vec3f(0, velocity.y, 0);
			if (velocity.y != 0 && enteringBlock(collider, position, nextPosY))
			{
				if (velocity.y < 0)
				{
					position.y = Maths::Floor(position.y + collider.min.y) - collider.min.y + 0.0001f;
				}
				else
				{
					position.y = Maths::Ceil(position.y + collider.max.y) - collider.max.y - 0.0001f;
				}

				velocity.y = 0;
				collided = true;
			}
			else
			{
				position.y += velocity.y;
			}

			// Revert velocity
			position -= velocity;

			entity.SetPosition(position);
			entity.SetVelocity(velocity);
		}

		return collided;
	}

	bool isOnGround()
	{
		AABB@ collider = entity.getCollider();
		if (collider is null) return false;

		Vec3f position = entity.getPosition();
		return enteringBlock(collider, position, position - Vec3f(0, 0.001f, 0));
	}

	private bool enteringBlock(AABB@ collider, Vec3f currentPos, Vec3f nextPos)
	{
		Vec3f floor = (currentPos + collider.min).floor();
		Vec3f ceil = (currentPos + collider.max).ceil();

		Vec3f min2 = Vec3f().max(nextPos + collider.min);
		Vec3f max2 = map.dimensions.min(nextPos + collider.max);

		for (int y = min2.y; y < max2.y; y++)
		for (int x = min2.x; x < max2.x; x++)
		for (int z = min2.z; z < max2.z; z++)
		{
			// Ignore blocks the collider is currently intersecting
			if (x >= floor.x && x < ceil.x &&
				y >= floor.y && y < ceil.y &&
				z >= floor.z && z < ceil.z)
			{
				continue;
			}

			if (map.isVisible(map.getBlock(x, y, z)))
			{
				return true;
			}
		}

		return false;
	}
}
