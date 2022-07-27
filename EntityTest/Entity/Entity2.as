#include "Entity.as"

shared class Entity2 : Entity
{
	string text = "";

	Entity2(u16 id)
	{
		super(id);
	}

	Entity2(u16 id, string text)
	{
		super(id);
		this.text = text;
	}

	u8 getType()
	{
		return 1;
	}

	void Render()
	{
		GUI::DrawTextCentered(text, Vec2f(100, 200), color_white);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_string(text);
	}

	bool deserialize(CBitStream@ bs)
	{
		return bs.saferead_string(text);
	}
}
