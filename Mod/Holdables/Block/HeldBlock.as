#include "IHoldable.as"
#include "PhysicalActor.as"

shared class HeldBlock : IHoldable
{
	private PhysicalActor@ actor;
	private u8 selectedIndex = 0;
	private SColor[] colors = {
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
	private CControls@ controls = getControls();
	private Mouse@ mouse = Mouse::getMouse();

	HeldBlock(PhysicalActor@ actor)
	{
		@this.actor = actor;
	}

	void Update()
	{
		if (!actor.isMyActor()) return;

		ChangeBlockColor();
		BlockPlacement();
	}

	void Draw()
	{
		if (!actor.isMyActor() || g_videorecording) return;

		actor.DrawCrosshair(0, 8, 1, color_white);

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

	private void BlockPlacement()
	{
		if (!mouse.isInControl()) return;

		CBlob@ blob = actor.getBlob();

		// Destroy block
		if (blob.isKeyJustPressed(key_action2))
		{
			Ray ray(actor.position + actor.cameraPosition, actor.rotation.dir());
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
			Ray ray(actor.position + actor.cameraPosition, actor.rotation.dir());
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

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_u8(selectedIndex);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return bs.saferead_u8(selectedIndex);
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u8(selectedIndex);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		return bs.saferead_u8(selectedIndex);
	}
}
