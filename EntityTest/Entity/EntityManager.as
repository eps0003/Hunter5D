#include "Entity.as"

shared class EntityManager
{
	private Entity@[] entities;

	private CRules@ rules = getRules();

	void AddEntity(Entity@ entity)
	{
		if (!entityExists(entity.getId()))
		{
			entities.push_back(entity);
			print("Added entity: " + entity.getId());
		}
	}

	void RemoveEntity(Entity@ entity)
	{
		RemoveEntity(entity.getId());
	}

	void RemoveEntity(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			if (entities[i].getId() == id)
			{
				entities.removeAt(i);
				print("Removed entity: " + entities[i].getId());
				break;
			}
		}
	}

	Entity@ getEntity(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];
			if (entity.getId() == id)
			{
				return entity;
			}
		}
		return null;
	}

	bool entityExists(u16 id)
	{
		return getEntity(id) !is null;
	}

	uint getEntityCount()
	{
		return entities.size();
	}

	void SyncEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			CBitStream bs;
			entities[i].Serialize(bs);
			rules.SendCommand(rules.getCommandID("sync entity"), bs, true);
		}
	}

	void DeserializeEntity(CBitStream@ bs)
	{
		u16 id;
		if (!bs.saferead_u16(id)) return;

		bs.ResetBitIndex();
		rules.set_CBitStream("_entity" + id, bs);
	}

	void UpdateEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];

			CBitStream@ bs = getEntityData(entity);
			if (bs is null) continue;

			entity.deserialize(bs);
		}
	}

	private CBitStream@ getEntityData(Entity@ entity)
	{
		CBitStream@ bs;
		rules.get_CBitStream("_entity" + entity.getId(), bs);
		return bs;
	}
}

namespace Entity
{
	shared EntityManager@ getManager()
	{
		EntityManager@ manager;
		if (!getRules().get("entity manager", @manager))
		{
			@manager = EntityManager();
			getRules().set("entity manager", @manager);
		}
		return manager;
	}
}
