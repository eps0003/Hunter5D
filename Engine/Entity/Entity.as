#include "EntityManager.as"

shared class Entity
{
	private u16 id = 0;

	Entity(u16 id)
	{
		this.id = id;
	}

	u16 getId()
	{
		return id;
	}

	u8 getType()
	{
		return 0;
	}

	void Kill()
	{
		Entity::getManager().RemoveEntity(id);
	}

	void Render()
	{

	}

	void SerializeInit(CBitStream@ bs)
	{
		SerializeTick(bs);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return deserializeTick(bs);
	}

	void SerializeTick(CBitStream@ bs)
	{

	}

	bool deserializeTick(CBitStream@ bs)
	{
		return true;
	}
}
