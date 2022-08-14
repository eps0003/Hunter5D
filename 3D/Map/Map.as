#include "Vec3f.as"
#include "MapSyncer.as"
#include "MapRenderer.as"

shared class Map
{
	private SColor[] blocks;
	Vec3f dimensions;
	uint blockCount = 0;

	private CRules@ rules = getRules();

	void Initialize(Vec3f dimensions)
	{
		this.dimensions = dimensions;
		blockCount = dimensions.x * dimensions.y * dimensions.z;
		blocks = array<SColor>(blockCount, 0);
	}

	void ClientSetBlockSafe(Vec3f position, SColor block)
	{
		if (isValidBlock(position))
		{
			ClientSetBlock(position.x, position.y, position.z, block);
		}
	}

	void ClientSetBlockSafe(int x, int y, int z, SColor block)
	{
		if (isValidBlock(x, y, z))
		{
			ClientSetBlock(x, y, z, block);
		}
	}

	void ClientSetBlockSafe(int index, SColor block)
	{
		if (isValidBlock(index))
		{
			ClientSetBlock(index, block);
		}
	}

	void ClientSetBlock(Vec3f position, SColor block)
	{
		ClientSetBlock(position.x, position.y, position.z, block);
	}

	void ClientSetBlock(int x, int y, int z, SColor block)
	{
		ClientSetBlock(posToIndex(x, y, z), block);
	}

	void ClientSetBlock(int index, SColor block)
	{
		if (canSetBlock(getLocalPlayer(), index, block))
		{
			SetBlock(index, block);
		}
	}

	void SetBlockSafe(Vec3f position, SColor block, CPlayer@ player = null)
	{
		if (isValidBlock(position))
		{
			SetBlock(position.x, position.y, position.z, block, player);
		}
	}

	void SetBlockSafe(int x, int y, int z, SColor block, CPlayer@ player = null)
	{
		if (isValidBlock(x, y, z))
		{
			SetBlock(x, y, z, block, player);
		}
	}

	void SetBlockSafe(int index, SColor block, CPlayer@ player = null)
	{
		if (isValidBlock(index))
		{
			SetBlock(index, block, player);
		}
	}

	void SetBlock(Vec3f position, SColor block, CPlayer@ player = null)
	{
		SetBlock(position.x, position.y, position.z, block, player);
	}

	void SetBlock(int x, int y, int z, SColor block, CPlayer@ player = null)
	{
		SetBlock(posToIndex(x, y, z), block, player);
	}

	void SetBlock(int index, SColor block, CPlayer@ player = null)
	{
		SColor oldBlock = blocks[index];
		if (oldBlock == block) return;

		blocks[index] = block;
	}

	void SetHealth(int index, u8 health, CPlayer@ player = null)
	{
		if (health == 0)
		{
			SetBlock(index, 0, player);
			return;
		}

		blocks[index].setAlpha(health);
	}

	void DamageBlockSafe(Vec3f position, uint damage, CPlayer@ player = null)
	{
		DamageBlockSafe(position.x, position.y, position.z, damage, player);
	}

	void DamageBlockSafe(int x, int y, int z, uint damage, CPlayer@ player = null)
	{
		if (isValidBlock(x, y, z))
		{
			DamageBlock(x, y, z, damage, player);
		}
	}

	void DamageBlockSafe(int index, uint damage, CPlayer@ player = null)
	{
		if (isValidBlock(index))
		{
			DamageBlock(index, damage, player);
		}
	}

	void DamageBlock(Vec3f position, uint damage, CPlayer@ player = null)
	{
		DamageBlock(position.x, position.y, position.z, damage, player);
	}

	void DamageBlock(int x, int y, int z, uint damage, CPlayer@ player = null)
	{
		DamageBlock(posToIndex(x, y, z), damage, player);
	}

	void DamageBlock(int index, uint damage, CPlayer@ player = null)
	{
		u8 newHealth = Maths::Clamp(blocks[index].getAlpha() - damage, 0, 255);
		SetHealth(index, newHealth, player);
	}

	SColor getBlockSafe(Vec3f position)
	{
		if (isValidBlock(position))
		{
			return getBlock(position.x, position.y, position.z);
		}
		return 0;
	}

	SColor getBlockSafe(int x, int y, int z)
	{
		if (isValidBlock(x, y, z))
		{
			return getBlock(x, y, z);
		}
		return 0;
	}

	SColor getBlockSafe(int index)
	{
		if (isValidBlock(index))
		{
			return getBlock(index);
		}
		return 0;
	}

	SColor getBlock(Vec3f position)
	{
		return getBlock(position.x, position.y, position.z);
	}

	SColor getBlock(int x, int y, int z)
	{
		return getBlock(posToIndex(x, y, z));
	}

	SColor getBlock(int index)
	{
		return blocks[index];
	}

	u8 getHealth(SColor block)
	{
		return block.getAlpha();
	}

	bool isValidBlock(Vec3f position)
	{
		return (
			position.x >= 0 && position.x < dimensions.x &&
			position.y >= 0 && position.y < dimensions.y &&
			position.z >= 0 && position.z < dimensions.z
		);
	}

	bool isValidBlock(int x, int y, int z)
	{
		return (
			x >= 0 && x < dimensions.x &&
			y >= 0 && y < dimensions.y &&
			z >= 0 && z < dimensions.z
		);
	}

	bool isValidBlock(int index)
	{
		return index >= 0 && index < blockCount;
	}

	//https://coderwall.com/p/fzni3g/bidirectional-translation-between-1d-and-3d-arrays
	int posToIndex(Vec3f position)
	{
		return posToIndex(position.x, position.y, position.z);
	}

	int posToIndex(int x, int y, int z)
	{
		return x + (z * dimensions.x) + (y * dimensions.x * dimensions.z);
	}

	Vec3f indexToPos(int index)
	{
		Vec3f vec;
		vec.x = index % dimensions.x;
		vec.z = Maths::Floor(index / dimensions.x) % dimensions.z;
		vec.y = Maths::Floor(index / (dimensions.x * dimensions.z));
		return vec;
	}

	bool canSetBlock(CPlayer@ player, int index, SColor block)
	{
		return true;
	}

	bool isVisible(SColor block)
	{
		return block.getAlpha() > 0;
	}

	bool isSolid(SColor block)
	{
		return isVisible(block);
	}

	bool isDestructible(SColor block)
	{
		return isVisible(block);
	}
}

namespace Map
{
	shared Map@ getMap()
	{
		Map@ map;
		if (!getRules().get("map", @map))
		{
			@map = Map();
			getRules().set("map", @map);
		}
		return map;
	}

	shared MapSyncer@ getSyncer()
	{
		MapSyncer@ syncer;
		if (!getRules().get("map syncer", @syncer))
		{
			@syncer = MapSyncer();
			getRules().set("map syncer", @syncer);
		}
		return syncer;
	}

	shared MapRenderer@ getRenderer()
	{
		MapRenderer@ renderer;
		if (!getRules().get("map renderer", @renderer))
		{
			@renderer = MapRenderer();
			getRules().set("map renderer", @renderer);
		}
		return renderer;
	}
}
