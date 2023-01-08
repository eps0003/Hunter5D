#include "Map.as"

shared class AABB
{
	Vec3f min;
	Vec3f max;
	Vec3f dim;
	Vec3f center;
	float radius; // Radius of a sphere that this box inscribes

	private Map@ map = Map::getMap();
	private Random random(XORRandom(9999));

	AABB(Vec3f min, Vec3f max)
	{
		this.min = min;
		this.max = max;
		UpdateProperties();
	}

	AABB(AABB aabb)
	{
		opAssign(aabb);
	}

	void opAssign(const AABB &in aabb)
	{
		min = aabb.min;
		max = aabb.max;
		dim = aabb.dim;
		center = aabb.center;
		radius = aabb.radius;
	}

	bool opEquals(const AABB &in aabb)
	{
		return min == aabb.min && max == aabb.max;
	}

	private void UpdateProperties()
	{
		dim = (max - min).abs();
		center = (max + min) * 0.5f;
		radius = dim.mag() * 0.5f;
	}

	bool intersectsAABB(Vec3f thisPos, AABB other, Vec3f otherPos)
	{
		for (uint i = 0; i < 3; i++)
		{
			if (thisPos[i] + min[i] >= otherPos[i] + other.max[i] || thisPos[i] + max[i] <= otherPos[i] + other.min[i])
			{
				return false;
			}
		}
		return true;
	}

	bool intersectsPoint(Vec3f worldPos, Vec3f point)
	{
		return (
			point.x > worldPos.x + min.x &&
			point.x < worldPos.x + max.x &&
			point.y > worldPos.y + min.y &&
			point.y < worldPos.y + max.y &&
			point.z > worldPos.z + min.z &&
			point.z < worldPos.z + max.z
		);
	}

	bool intersectsMapEdge(Vec3f worldPos)
	{
		Vec3f dim = map.dimensions;
		return (
			worldPos.x + min.x < 0 ||
			worldPos.x + max.x > dim.x ||
			worldPos.z + min.z < 0 ||
			worldPos.z + max.z > dim.z
		);
	}

	Vec3f getRandomPoint()
	{
		return Vec3f(
			min.x + random.NextFloat() * dim.x,
			min.y + random.NextFloat() * dim.y,
			min.z + random.NextFloat() * dim.z
		);
	}

	bool enteringBlock(Vec3f currentPos, Vec3f worldPos)
	{
		Vec3f floor = (currentPos + min).floor();
		Vec3f ceil = (currentPos + max).ceil();

		Vec3f min2 = Vec3f().max(worldPos + min);
		Vec3f max2 = map.dimensions.min(worldPos + max);

		for (int y = min2.y; y < max2.y; y++)
		for (int x = min2.x; x < max2.x; x++)
		for (int z = min2.z; z < max2.z; z++)
		{
			// Ignore blocks the AABB is currently intersecting
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

	bool intersectsBlock(Vec3f worldPos, Vec3f blockWorldPos)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			if (Vec3f(x, y, z) == blockWorldPos)
			{
				return true;
			}
		}
		return false;
	}

	void Serialize(CBitStream@ bs)
	{
		min.Serialize(bs);
		max.Serialize(bs);
	}

	bool deserialize(CBitStream@ bs)
	{
		bool success = min.deserialize(bs) && max.deserialize(bs);
		if (success) UpdateProperties();
		return success;
	}
}
