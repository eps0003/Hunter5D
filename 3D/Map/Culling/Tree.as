#include "Map.as"
#include "Camera.as"

shared class Tree
{
	private Branch@ branch;

	private Camera@ camera = Camera::getCamera();

	Tree(MapRenderer@ mapRenderer)
	{
		@branch = Branch(mapRenderer, Vec3f(), Vec3f(mapRenderer.chunkDimensions.max()));
	}

	uint RenderVisibleChunks()
	{
		return branch.RenderVisibleChunks(camera.getFrustum(), camera.getPosition());
	}
}

shared class Branch
{
	private AABB@ worldBounds;

	private Branch@ branch0;
	private Branch@ branch1;
	private Branch@ branch2;
	private Branch@ branch3;
	private Branch@ branch4;
	private Branch@ branch5;
	private Branch@ branch6;
	private Branch@ branch7;

	private Chunk@ chunk0;
	private Chunk@ chunk1;
	private Chunk@ chunk2;
	private Chunk@ chunk3;
	private Chunk@ chunk4;
	private Chunk@ chunk5;
	private Chunk@ chunk6;
	private Chunk@ chunk7;

	Branch(MapRenderer@ mapRenderer, Vec3f min, Vec3f max)
	{
		@worldBounds = AABB(min * mapRenderer.chunkSize, max * mapRenderer.chunkSize);

		Vec3f dim = max - min;
		Vec3f chunkDim = mapRenderer.chunkDimensions;

		// Check if branch can be subdivided
		if (dim.max() > 2)
		{
			Vec3f half = min + (dim * 0.5f).floor();

			// Subdivide bottom half
			@branch0 = Branch(mapRenderer, Vec3f(min.x, min.y, min.z), Vec3f(half.x, half.y, half.z));

			if (half.x < chunkDim.x)
			{
				@branch1 = Branch(mapRenderer, Vec3f(half.x, min.y, min.z), Vec3f(max.x, half.y, half.z));
			}

			if (half.z < chunkDim.z)
			{
				@branch2 = Branch(mapRenderer, Vec3f(min.x, min.y, half.z), Vec3f(half.x, half.y, max.z));

				if (half.x < chunkDim.x)
				{
					@branch3 = Branch(mapRenderer, Vec3f(half.x, min.y, half.z), Vec3f(max.x, half.y, max.z));
				}
			}

			// Subdivide top half
			if (half.y < chunkDim.y)
			{
				@branch4 = Branch(mapRenderer, Vec3f(min.x, half.y, min.z), Vec3f(half.x, max.y, half.z));

				if (half.x < chunkDim.x)
				{
					@branch5 = Branch(mapRenderer, Vec3f(half.x, half.y, min.z), Vec3f(max.x, max.y, half.z));
				}

				if (half.z < chunkDim.z)
				{
					@branch6 = Branch(mapRenderer, Vec3f(min.x, half.y, half.z), Vec3f(half.x, max.y, max.z));

					if (half.x < chunkDim.x)
					{
						@branch7 = Branch(mapRenderer, Vec3f(half.x, half.y, half.z), Vec3f(max.x, max.y,  max.z));
					}
				}
			}
		}
		else
		{
			// Get bottom chunks
			@chunk0 = mapRenderer.getChunkSafe(min.x, min.y, min.z);

			if (dim.x == 2)
			{
				@chunk1 = mapRenderer.getChunkSafe(min.x + 1, min.y, min.z);
			}

			if (dim.z == 2)
			{
				@chunk2 = mapRenderer.getChunkSafe(min.x, min.y, min.z + 1);

				if (dim.x == 2)
				{
					@chunk3 = mapRenderer.getChunkSafe(min.x + 1, min.y, min.z + 1);
				}
			}

			// Get top chunks
			if (dim.y == 2 && max.y <= chunkDim.y)
			{
				@chunk4 = mapRenderer.getChunkSafe(min.x, min.y + 1, min.z);

				if (dim.x == 2)
				{
					@chunk5 = mapRenderer.getChunkSafe(min.x + 1, min.y + 1, min.z);
				}

				if (dim.z == 2)
				{
					@chunk6 = mapRenderer.getChunkSafe(min.x, min.y + 1, min.z + 1);

					if (dim.x == 2)
					{
						@chunk7 = mapRenderer.getChunkSafe(min.x + 1, min.y + 1, min.z + 1);
					}
				}
			}
		}
	}

	uint RenderVisibleChunks(Frustum@ frustum, Vec3f camPos)
	{
		uint visibleChunkCount = 0;

		if (frustum.containsSphere(worldBounds.center - camPos, worldBounds.radius))
		{
			if (chunk0 !is null)
			{
				if (frustum.containsSphere(chunk0.getBounds().center - camPos, chunk0.getBounds().radius))
				{
					chunk0.Render();
					visibleChunkCount++;
				}

				if (chunk1 !is null && frustum.containsSphere(chunk1.getBounds().center - camPos, chunk1.getBounds().radius))
				{
					chunk1.Render();
					visibleChunkCount++;
				}

				if (chunk2 !is null && frustum.containsSphere(chunk2.getBounds().center - camPos, chunk2.getBounds().radius))
				{
					chunk2.Render();
					visibleChunkCount++;
				}

				if (chunk3 !is null && frustum.containsSphere(chunk3.getBounds().center - camPos, chunk3.getBounds().radius))
				{
					chunk3.Render();
					visibleChunkCount++;
				}

				if (chunk4 !is null && frustum.containsSphere(chunk4.getBounds().center - camPos, chunk4.getBounds().radius))
				{
					chunk4.Render();
					visibleChunkCount++;
				}

				if (chunk5 !is null && frustum.containsSphere(chunk5.getBounds().center - camPos, chunk5.getBounds().radius))
				{
					chunk5.Render();
					visibleChunkCount++;
				}

				if (chunk6 !is null && frustum.containsSphere(chunk6.getBounds().center - camPos, chunk6.getBounds().radius))
				{
					chunk6.Render();
					visibleChunkCount++;
				}

				if (chunk7 !is null && frustum.containsSphere(chunk7.getBounds().center - camPos, chunk7.getBounds().radius))
				{
					chunk7.Render();
					visibleChunkCount++;
				}
			}
			else
			{
				visibleChunkCount += branch0.RenderVisibleChunks(frustum, camPos);
				if (branch1 !is null) visibleChunkCount += branch1.RenderVisibleChunks(frustum, camPos);
				if (branch2 !is null) visibleChunkCount += branch2.RenderVisibleChunks(frustum, camPos);
				if (branch3 !is null) visibleChunkCount += branch3.RenderVisibleChunks(frustum, camPos);
				if (branch4 !is null) visibleChunkCount += branch4.RenderVisibleChunks(frustum, camPos);
				if (branch5 !is null) visibleChunkCount += branch5.RenderVisibleChunks(frustum, camPos);
				if (branch6 !is null) visibleChunkCount += branch6.RenderVisibleChunks(frustum, camPos);
				if (branch7 !is null) visibleChunkCount += branch7.RenderVisibleChunks(frustum, camPos);
			}
		}

		return visibleChunkCount;
	}
}
