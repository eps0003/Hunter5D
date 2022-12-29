#include "PhysicalActor.as"

shared class SandboxActor : PhysicalActor
{
	u8 selectedIndex = 0;
	SColor[] colors = {
		SColor(255, 229,  59,  68), // Red
		SColor(255, 255, 173,  52), // Orange
		SColor(255, 255, 231,  98), // Yellow
		SColor(255,  99, 198,  77), // Lime
		SColor(255,  38,  92,  66), // Dark green
		SColor(255,   0, 149, 233), // Light blue
		SColor(255,  18,  79, 136), // Dark blue
		SColor(255, 104,  55, 108), // Purple
		SColor(255,  24,  20,  37)  // Dark purple
	};

	private Map@ map = Map::getMap();
	private Driver@ driver = getDriver();

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

		if (isMyActor())
		{
			ChangeBlockColor();
			BlockPlacement();
		}
	}

	void Draw()
	{
		if (isMyActor() && !g_videorecording)
		{
			DrawCrosshair(0, 8, 1, color_white);

			int n = colors.size();
			Vec2f center = driver.getScreenCenterPos();
			int spacing = 10;
			int selectedBorder = 4;
			int size = 50;
			int numOffset = 12;
			int y = 20;

			for (int i = 0; i < n; i++)
			{
				SColor color = colors[i];

				float offset = i - (n / 2.0f);
				int x = center.x + offset * size + offset * spacing;

				if (i == selectedIndex)
				{
					GUI::DrawRectangle(
						Vec2f(x - selectedBorder, y - selectedBorder),
						Vec2f(x + size + selectedBorder, y + size + selectedBorder),
						color_white
					);
				}

				GUI::DrawRectangle(Vec2f(x, y), Vec2f(x + size, y + size), color);
				GUI::DrawTextCentered(
					"" + (i + 1),
					Vec2f(x + size - numOffset, y + size - numOffset),
					color_white
				);
			}
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
					SColor block = colors[selectedIndex];
					map.ClientSetBlock(blockPos, block);
					print("Placed block at " + blockPos.toString());
				}
			}
		}
	}

	private void ChangeBlockColor()
	{
		for (uint i = 0; i < 9; i++)
		{
			if (controls.isKeyJustPressed(KEY_KEY_1 + i))
			{
				selectedIndex = i;
				break;
			}
		}

		s8 scrollDir = 0;
		if (controls.mouseScrollUp) scrollDir--;
		if (controls.mouseScrollDown) scrollDir++;
		selectedIndex = (selectedIndex + scrollDir + colors.size()) % colors.size();
	}
}
