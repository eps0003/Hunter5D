#include "IEntity.as"

shared interface IEntityManager
{
	IEntity@[] getEntities();

	IEntity@ getEntity(u16 id);

	void AddEntity(IEntity@ entity);

	void RemoveEntity(IEntity@ entity);
	void RemoveEntity(u16 id);

	bool entityExists(u16 id);

	uint getEntityCount();
}
