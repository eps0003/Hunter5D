#include "Map.as"
#include "Chunk.as"
#include "FaceEnums.as"

shared class MapRenderer
{
	CRules@ rules = getRules();
	Map@ map;

	private Chunk@[] chunks;
	private u8[] faceFlags;

	// Chunk size cannot be larger than 15 due to the u16 index buffer limit
	// Chunks won't render property at larger chunk sizes on a checkboard map
	u8 chunkSize = 8;
	Vec3f chunkDimensions;
	uint chunkCount = 0;

	SMaterial@ material = SMaterial();

	private float shadeIntensity = 0.07f;
	private u8[] shadeScale = { 2, 3, 5, 0, 1, 4 };

	void Init()
	{
		@map = Map::getMap();

		Texture::createFromFile("pixel", "Pixel.png");
		material.AddTexture("pixel");

		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
		material.SetMaterialType(SMaterial::TRANSPARENT_ALPHA_CHANNEL_REF);

		faceFlags = array<u8>(map.blockCount, FaceFlag::None);

		chunkDimensions = (map.dimensions / chunkSize).ceil();
		chunkCount = chunkDimensions.x * chunkDimensions.y * chunkDimensions.z;
		chunks.set_length(chunkCount);
	}

	// Generates the relevant chunk meshes for a block at the specified index
	void GenerateMesh(int index)
	{
		if (map is null) return;

		Vec3f worldPos = map.indexToPos(index);
		Vec3f chunkPos = worldPosToChunkPos(worldPos);
		Chunk@ chunk = getChunkSafe(chunkPos);
		if (chunk is null) return;

		int x = worldPos.x;
		int y = worldPos.y;
		int z = worldPos.z;

		int cx = chunkPos.x;
		int cy = chunkPos.y;
		int cz = chunkPos.z;

		int xMod = x % chunkSize;
		int yMod = y % chunkSize;
		int zMod = z % chunkSize;

		UpdateBlockFaces(index, x, y, z);

		bool visible = map.isVisible(map.getBlock(index));

		// Update face flags of this block and adjacent blocks

		if (x > 0)
		{
			index = map.posToIndex(x - 1, y, z);
			if (visible)
				faceFlags[index] &= ~FaceFlag::Right;
			else if (map.isVisible(map.getBlock(index)))
				faceFlags[index] |= FaceFlag::Right;
		}

		if (x + 1 < map.dimensions.x)
		{
			index = map.posToIndex(x + 1, y, z);
			if (visible)
				faceFlags[index] &= ~FaceFlag::Left;
			else if (map.isVisible(map.getBlock(index)))
				faceFlags[index] |= FaceFlag::Left;
		}

		if (z > 0)
		{
			index = map.posToIndex(x, y, z - 1);
			if (visible)
				faceFlags[index] &= ~FaceFlag::Back;
			else if (map.isVisible(map.getBlock(index)))
				faceFlags[index] |= FaceFlag::Back;
		}

		if (z + 1 < map.dimensions.z)
		{
			index = map.posToIndex(x, y, z + 1);
			if (visible)
				faceFlags[index] &= ~FaceFlag::Front;
			else if (map.isVisible(map.getBlock(index)))
				faceFlags[index] |= FaceFlag::Front;
		}

		if (y > 0)
		{
			index = map.posToIndex(x, y - 1, z);
			if (visible)
				faceFlags[index] &= ~FaceFlag::Up;
			else if (map.isVisible(map.getBlock(index)))
				faceFlags[index] |= FaceFlag::Up;
		}

		if (y + 1 < map.dimensions.y)
		{
			index = map.posToIndex(x, y + 1, z);
			if (visible)
				faceFlags[index] &= ~FaceFlag::Down;
			else if (map.isVisible(map.getBlock(index)))
				faceFlags[index] |= FaceFlag::Down;
		}

		// Rebuild this chunk and adjacent chunks if required

		chunk.Rebuild();

		if (xMod == 0 && cx > 0)
		{
			@chunk = getChunk(cx - 1, cy, cz);
			if (chunk !is null) chunk.Rebuild();
		}

		if (xMod == chunkSize - 1 && cx + 1 < chunkDimensions.x)
		{
			@chunk = getChunk(cx + 1, cy, cz);
			if (chunk !is null) chunk.Rebuild();
		}

		if (yMod == 0 && cy > 0)
		{
			@chunk = getChunk(cx, cy - 1, cz);
			if (chunk !is null) chunk.Rebuild();
		}

		if (yMod == chunkSize - 1 && cy + 1 < chunkDimensions.y)
		{
			@chunk = getChunk(cx, cy + 1, cz);
			if (chunk !is null) chunk.Rebuild();
		}

		if (zMod == 0 && cz > 0)
		{
			@chunk = getChunk(cx, cy, cz - 1);
			if (chunk !is null) chunk.Rebuild();
		}

		if (zMod == chunkSize - 1 && cz + 1 < chunkDimensions.z)
		{
			@chunk = getChunk(cx, cy, cz + 1);
			if (chunk !is null) chunk.Rebuild();
		}
	}

	bool isValidChunk(Vec3f position)
	{
		return (
			position.x >= 0 && position.x < chunkDimensions.x &&
			position.y >= 0 && position.y < chunkDimensions.y &&
			position.z >= 0 && position.z < chunkDimensions.z
		);
	}

	bool isValidChunk(int x, int y, int z)
	{
		return (
			x >= 0 && x < chunkDimensions.x &&
			y >= 0 && y < chunkDimensions.y &&
			z >= 0 && z < chunkDimensions.z
		);
	}

	bool isValidChunk(int index)
	{
		return index >= 0 && index < chunks.size();
	}

	void Render()
	{
		material.SetVideoMaterial();

		for (uint i = 0; i < chunks.size(); i++)
		{
			chunks[i].Render();
		}
	}

	void InitBlockFaces(int index)
	{
		Vec3f pos = map.indexToPos(index);

		faceFlags[index] = FaceFlag::All;

		if (pos.x > 0 && faceFlags[index - 1] != FaceFlag::None)
		{
			faceFlags[index - 1] &= ~FaceFlag::Right;
			faceFlags[index] &= ~FaceFlag::Left;
		}
		if (pos.z > 0 && faceFlags[index - map.dimensions.x] != FaceFlag::None)
		{
			faceFlags[index - map.dimensions.x] &= ~FaceFlag::Back;
			faceFlags[index] &= ~FaceFlag::Front;
		}
		if (pos.y > 0 && faceFlags[index - map.dimensions.x * map.dimensions.z] != FaceFlag::None)
		{
			faceFlags[index - map.dimensions.x * map.dimensions.z] &= ~FaceFlag::Up;
			faceFlags[index] &= ~FaceFlag::Down;
		}
	}

	private void UpdateBlockFaces(int index, int x, int y, int z)
	{
		u8 faces = FaceFlag::None;

		if (map.isVisible(map.getBlock(index)))
		{
			if (x == 0 || !map.isVisible(map.getBlock(x - 1, y, z)))
			{
				faces |= FaceFlag::Left;
			}

			if (x == map.dimensions.x - 1 || !map.isVisible(map.getBlock(x + 1, y, z)))
			{
				faces |= FaceFlag::Right;
			}

			if (y == 0 || !map.isVisible(map.getBlock(x, y - 1, z)))
			{
				faces |= FaceFlag::Down;
			}

			if (y == map.dimensions.y - 1 || !map.isVisible(map.getBlock(x, y + 1, z)))
			{
				faces |= FaceFlag::Up;
			}

			if (z == 0 || !map.isVisible(map.getBlock(x, y, z - 1)))
			{
				faces |= FaceFlag::Front;
			}

			if (z == map.dimensions.z - 1 || !map.isVisible(map.getBlock(x, y, z + 1)))
			{
				faces |= FaceFlag::Back;
			}
		}

		faceFlags[index] = faces;
	}

	void SetChunk(int index, Chunk@ chunk)
	{
		@chunks[index] = chunk;
	}

	Chunk@ getChunkSafe(Vec3f position)
	{
		if (isValidChunk(position))
		{
			return getChunk(position.x, position.y, position.z);
		}
		return null;
	}

	Chunk@ getChunkSafe(int x, int y, int z)
	{
		if (isValidChunk(x, y, z))
		{
			return getChunk(x, y, z);
		}
		return null;
	}

	Chunk@ getChunkSafe(int index)
	{
		if (isValidChunk(index))
		{
			return getChunk(index);
		}
		return null;
	}

	Chunk@ getChunk(Vec3f position)
	{
		return getChunk(position.x, position.y, position.z);
	}


	Chunk@ getChunk(int x, int y, int z)
	{
		return getChunk(chunkPosToChunkIndex(x, y, z));
	}

	Chunk@ getChunk(int index)
	{
		return chunks[index];
	}

	u8 getFaceFlags(int index)
	{
		return faceFlags[index];
	}

	bool blockHasFace(int index, u8 face)
	{
		return (faceFlags[index] & face) == face;
	}

	Vec3f worldPosToChunkPos(Vec3f position)
	{
		return position / chunkSize;
	}

	Vec3f worldPosToChunkPos(float x, float y, float z)
	{
		return worldPosToChunkPos(Vec3f(x, y, z));
	}

	int chunkPosToChunkIndex(Vec3f position)
	{
		return chunkPosToChunkIndex(position.x, position.y, position.z);
	}

	int chunkPosToChunkIndex(int x, int y, int z)
	{
		return x + (z * chunkDimensions.x) + (y * chunkDimensions.x * chunkDimensions.z);
	}

	Vec3f chunkIndexToPos(int index)
	{
		Vec3f vec;
		vec.x = index % chunkDimensions.x;
		vec.z = Maths::Floor(index / chunkDimensions.x) % chunkDimensions.z;
		vec.y = Maths::Floor(index / (chunkDimensions.x * chunkDimensions.z));
		return vec;
	}

	private void AddIndices(Vertex[]@ vertices, u16[]@ indices)
	{
		uint n = vertices.size();
		indices.push_back(n - 4);
		indices.push_back(n - 3);
		indices.push_back(n - 1);
		indices.push_back(n - 3);
		indices.push_back(n - 2);
		indices.push_back(n - 1);
	}

	SColor getBlockFaceColor(SColor block, u8 face)
	{
		float shade = 1 - shadeIntensity * shadeScale[face];
		float health = map.getHealth(block) / 255.0f;

		return SColor(255,
			block.getRed() * shade * health,
			block.getGreen() * shade * health,
			block.getBlue() * shade * health
		);
	}
}
