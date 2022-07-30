#include "EntityManager.as"
#include "Entities.as"

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
		error("Entity doesn't have a type set: " + id);
		return 0;
	}

	void Kill()
	{
		Entity::getManager().RemoveEntity(id);
	}

	void Update()
	{

	}

	void Render()
	{

	}

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_u16(id);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return bs.saferead_u16(id);
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u16(id);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		return bs.saferead_u16(id);
	}
}
