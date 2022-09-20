#include "Map.as"

shared class Chunk
{
	private Map@ map;
	private MapRenderer@ renderer;

	private Vec3f chunkPosition;
	private Vec3f worldPosition;
	private uint worldIndex;
	private Vec3f dimensions;
	private uint blockCount;

	private SMesh mesh;
	private Vertex[] vertices;
	private u16[] indices;

	private bool rebuild = true;

	Chunk(MapRenderer@ renderer, uint chunkIndex)
	{
		@this.renderer = renderer;
		@map = renderer.map;

		chunkPosition = renderer.chunkIndexToPos(chunkIndex);
		worldPosition = chunkPosition * renderer.chunkSize;
		worldIndex = map.posToIndex(worldPosition);
		dimensions = (worldPosition + renderer.chunkSize).min(map.dimensions) - worldPosition;
		blockCount = dimensions.product();

		mesh.SetHardwareMapping(SMesh::STATIC);

		GenerateMesh();
	}

	uint getComplexity()
	{
		return blockCount + vertices.size();
	}

	void Rebuild()
	{
		rebuild = true;
	}

	void Render()
	{
		if (rebuild)
		{
			GenerateMesh();
		}

		if (!vertices.empty())
		{
			mesh.RenderMesh();
		}
	}

	private void AddIndices()
	{
		uint n = vertices.size();
		indices.push_back(n - 4);
		indices.push_back(n - 3);
		indices.push_back(n - 1);
		indices.push_back(n - 3);
		indices.push_back(n - 2);
		indices.push_back(n - 1);
	}

	void GenerateMesh()
	{
		rebuild = false;

		vertices.clear();
		indices.clear();

		// Copy worldIndex so it can be incremented
		uint worldIndex = this.worldIndex;

		uint chunkX = 0;
		uint chunkY = 0;
		uint chunkZ = 0;

		uint x;
		uint y;
		uint z;

		SColor block;
		SColor col;

		float x1 = 0;
		float y1 = 0;
		float x2 = 1;
		float y2 = 1;

		for (uint i = 0; i < blockCount; i++)
		{
			if (renderer.getFaceFlags(worldIndex) != FaceFlag::None)
			{
				block = map.getBlock(worldIndex);

				x = worldPosition.x + chunkX;
				y = worldPosition.y + chunkY;
				z = worldPosition.z + chunkZ;

				if (renderer.blockHasFace(worldIndex, FaceFlag::Left))
				{
					col = renderer.getBlockFaceColor(block, Face::Left);
					vertices.push_back(Vertex(x, y + 1, z + 1, x1, y1, col));
					vertices.push_back(Vertex(x, y + 1, z    , x2, y1, col));
					vertices.push_back(Vertex(x, y    , z    , x2, y2, col));
					vertices.push_back(Vertex(x, y    , z + 1, x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(worldIndex, FaceFlag::Right))
				{
					col = renderer.getBlockFaceColor(block, Face::Right);
					vertices.push_back(Vertex(x + 1, y + 1, z    , x1, y1, col));
					vertices.push_back(Vertex(x + 1, y + 1, z + 1, x2, y1, col));
					vertices.push_back(Vertex(x + 1, y    , z + 1, x2, y2, col));
					vertices.push_back(Vertex(x + 1, y    , z    , x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(worldIndex, FaceFlag::Down))
				{
					col = renderer.getBlockFaceColor(block, Face::Down);
					vertices.push_back(Vertex(x + 1, y, z + 1, x1, y1, col));
					vertices.push_back(Vertex(x    , y, z + 1, x2, y1, col));
					vertices.push_back(Vertex(x    , y, z    , x2, y2, col));
					vertices.push_back(Vertex(x + 1, y, z    , x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(worldIndex, FaceFlag::Up))
				{
					col = renderer.getBlockFaceColor(block, Face::Up);
					vertices.push_back(Vertex(x    , y + 1, z + 1, x1, y1, col));
					vertices.push_back(Vertex(x + 1, y + 1, z + 1, x2, y1, col));
					vertices.push_back(Vertex(x + 1, y + 1, z    , x2, y2, col));
					vertices.push_back(Vertex(x    , y + 1, z    , x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(worldIndex, FaceFlag::Front))
				{
					col = renderer.getBlockFaceColor(block, Face::Front);
					vertices.push_back(Vertex(x    , y + 1, z, x1, y1, col));
					vertices.push_back(Vertex(x + 1, y + 1, z, x2, y1, col));
					vertices.push_back(Vertex(x + 1, y    , z, x2, y2, col));
					vertices.push_back(Vertex(x    , y    , z, x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(worldIndex, FaceFlag::Back))
				{
					col = renderer.getBlockFaceColor(block, Face::Back);
					vertices.push_back(Vertex(x + 1, y + 1, z + 1, x1, y1, col));
					vertices.push_back(Vertex(x    , y + 1, z + 1, x2, y1, col));
					vertices.push_back(Vertex(x    , y    , z + 1, x2, y2, col));
					vertices.push_back(Vertex(x + 1, y    , z + 1, x1, y2, col));
					AddIndices();
				}
			}

			chunkX++;
			worldIndex++;
			if (chunkX == dimensions.x)
			{
				chunkX = 0;
				chunkZ++;
				worldIndex += map.dimensions.x - dimensions.x;
				if (chunkZ == dimensions.z)
				{
					chunkZ = 0;
					chunkY++;
					worldIndex += (map.dimensions.x * map.dimensions.z) - (map.dimensions.x * dimensions.z);
				}
			}
		}

		if (!vertices.empty())
		{
			mesh.SetVertex(vertices);
			mesh.SetIndices(indices);
			mesh.SetDirty(SMesh::VERTEX_INDEX);
			mesh.BuildMesh();
		}
		else
		{
			mesh.Clear();
		}
	}
}
