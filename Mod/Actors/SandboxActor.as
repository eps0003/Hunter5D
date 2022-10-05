#include "PhysicalActor.as"

shared class SandboxActor : PhysicalActor
{
	private Map@ map = Map::getMap();

	SandboxActor(u16 id, CPlayer@ player, Vec3f position)
	{
		super(id, player, position);
	}

	u8 getType()
	{
		return EntityType::SandboxActor;
	}

	void Update()
	{
		PhysicalActor::Update();

		if (player.isMyPlayer())
		{
			BlockPlacement();
		}
	}

	void Draw()
	{
		if (player.isMyPlayer() && !g_videorecording)
		{
			DrawCrosshair(0, 8, 1, color_white);
		}
	}

	private void BlockPlacement()
	{
		if (!mouse.isInControl()) return;

		CBlob@ blob = player.getBlob();
		if (blob is null) return;

		// Destroy block
		if (blob.isKeyJustPressed(key_action2))
		{
			Ray ray(position + cameraPosition, rotation.dir());
			RaycastInfo@ raycastInfo;
			if (ray.raycastBlock(10, @raycastInfo))
			{
				Vec3f blockPos = raycastInfo.hitWorldPos;
				map.ClientSetBlock(raycastInfo.hitWorldPos, 0);
				print("Destroyed block at " + blockPos.toString());
			}
		}

		// Place block
		if (blob.isKeyJustPressed(key_action1))
		{
			Ray ray(position + cameraPosition, rotation.dir());
			RaycastInfo@ raycastInfo;
			if (ray.raycastBlock(10, @raycastInfo))
			{
				Vec3f blockPos = raycastInfo.hitWorldPos + raycastInfo.normal;
				if (map.isValidBlock(blockPos) && !map.isVisible(map.getBlock(blockPos)))
				{
					SColor block = SColor(255, 255, 150, 150);
					map.ClientSetBlock(blockPos, block);
					print("Placed block at " + blockPos.toString());
				}
			}
		}
	}
}
