#include "Actor.as"

shared class Actor1 : Actor
{
	private uint tick = 0;

	Actor1(u16 id)
	{
		super(id);
	}

	Actor1(u16 id, CPlayer@ player)
	{
		super(id, player);
	}

	u8 getType()
	{
		return 2;
	}

	void Render()
	{
		GUI::DrawTextCentered(player.getUsername() + ": " + tick + " " + getGameTime(), Vec2f(100, 200 + id * 20), color_white);
	}

	void SerializeTickClient(CBitStream@ bs)
	{
		bs.write_u32(tick = getGameTime());
	}

	bool deserializeTickClient(CBitStream@ bs)
	{
		return bs.saferead_u32(tick);
	}
}
