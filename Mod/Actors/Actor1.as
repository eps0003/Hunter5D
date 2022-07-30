#include "Actor.as"

shared class Actor1 : Actor
{
	private uint tick = 0;
	private Vec2f position;

	Actor1(u16 id, CPlayer@ player, Vec2f position)
	{
		super(id, player);
		this.position = position;
	}

	u8 getType()
	{
		return EntityType::Actor1;
	}

	void Update()
	{
		if (player.isMyPlayer())
		{
			Vec2f dir;

			CControls@ controls = getControls();
			if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y--;
			if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y++;
			if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
			if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;

			dir.Normalize();

			position += dir * 10;
		}
	}

	void Render()
	{
		GUI::DrawTextCentered(player.getUsername() + ": " + tick + " " + getGameTime(), position, color_white);
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		Actor::SerializeTickClient(bs);
		bs.write_u32(tick = getGameTime());
		bs.write_Vec2f(position);
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		if (!Actor::deserializeTickClient(bs)) return false;
		if (!bs.saferead_u32(tick)) return false;
		if (!bs.saferead_Vec2f(position)) return false;
		return true;
	}

	void SerializeInit(CBitStream@ bs)
	{
		Actor::SerializeInit(bs);
		bs.write_Vec2f(position);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!Actor::deserializeInit(bs)) return false;
		if (!bs.saferead_Vec2f(position)) return false;
		return true;
	}
}
