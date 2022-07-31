#include "Actor.as"
#include "Interpolation.as"

shared class Actor1 : Actor
{
	private uint tick = 0;
	private Vec2f position;
	private Vec2f prevPosition;

	Actor1(u16 id, CPlayer@ player, Vec2f position)
	{
		super(id, player);
		this.position = position;
		this.prevPosition = position;
	}

	u8 getType()
	{
		return EntityType::Actor1;
	}

	void PreUpdate()
	{
		prevPosition = position;
	}

	void Update()
	{
		if (player.isMyPlayer())
		{
			tick = getGameTime();

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
		string text = player.getUsername() + ": " + tick + " " + getGameTime();
		Vec2f pos = Vec2f_lerp(prevPosition, position, Interpolation::getFrameTime());
		GUI::DrawTextCentered(text, pos, color_white);
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		Actor::SerializeTickClient(bs);
		bs.write_u32(tick);
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
