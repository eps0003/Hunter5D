#include "Entity.as"

shared class Entity1 : Entity
{
	int val = 0;

	Entity1(u16 id)
	{
		super(id);
	}

	Entity1(u16 id, int val)
	{
		super(id);
		this.val = val;
	}

	u8 getType()
	{
		return 0;
	}

	void Render()
	{
		GUI::DrawTextCentered(""+val, Vec2f(100, 100), color_white);
	}

	void SerializeInit(CBitStream@ bs)
	{
		Entity::SerializeInit(bs);
		bs.write_s32(val);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!Entity::deserializeInit(bs)) return false;
		if (!bs.saferead_s32(val)) return false;
		return true;
	}
}
