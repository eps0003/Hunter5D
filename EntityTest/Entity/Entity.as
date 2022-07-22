#include "EntityManager.as"
#include "Serializable.as"

shared class Entity : Serializable
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

	void Kill()
	{
		Entity::getManager().RemoveEntity(id);
	}

	void Serialize(CBitStream@ bs)
	{

	}

	bool deserialize(CBitStream@ bs)
	{
		return true;
	}
}
