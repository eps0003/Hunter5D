#include "IEntityManager.as"

shared class EntityManager : IEntityManager
{
	private IEntity@[]@ entities;

	private CRules@ rules = getRules();

	EntityManager(IEntity@[]@ entities)
	{
		@this.entities = entities;
	}

	IEntity@[] getEntities()
	{
		return entities;
	}

	IEntity@ getEntity(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			IEntity@ entity = entities[i];
			if (entity.getId() == id)
			{
				return entity;
			}
		}
		return null;
	}

	void AddEntity(IEntity@ entity)
	{
		u16 id = entity.getId();
		u8 type = entity.getType();

		if (entityExists(id))
		{
			error("Attempted to add entity with ID already in use: " + id);
			printTrace();
			return;
		}

		entities.push_back(entity);
		print("Added entity: " + entity.getName());

		entity.Init();

		if (isServer())
		{
			CBitStream bs;
			bs.write_u8(type);
			entity.SerializeInit(bs);
			Command::Send("create entity", bs, true);
		}
	}

	void RemoveEntity(IEntity@ entity)
	{
		RemoveEntity(entity.getId());
	}

	void RemoveEntity(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i].getId() == id)
			{
				RemoveEntityAtIndex(i);
				return;
			}
		}

		error("Attempted to remove entity with invalid ID: " + id);
		printTrace();
	}

	private void RemoveEntityAtIndex(uint index)
	{
		IEntity@ entity = entities[index];
		u16 id = entity.getId();

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(id);
			Command::Send("remove entity", bs, true);
		}

		entities.removeAt(index);
		print("Removed entity: " + entity.getName());
	}

	bool entityExists(u16 id)
	{
		return getEntity(id) !is null;
	}

	uint getEntityCount()
	{
		return entities.size();
	}
}

namespace Entity
{
	shared IEntityManager@ getManager()
	{
		IEntityManager@ manager;
		if (!getRules().get("entity manager", @manager))
		{
			IEntity@[]@ entities;
			getRules().get("entities", @entities);

			@manager = EntityManager(entities);
			getRules().set("entity manager", @manager);
		}
		return manager;
	}
}
