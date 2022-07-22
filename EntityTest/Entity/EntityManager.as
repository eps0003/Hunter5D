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
		uint index = bs.getBitIndex();

		u16 id;
		if (!bs.saferead_u16(id)) return;

		string key = "_entity" + id;
		if (!rules.exists(key))
		{
			AddEntity(Entity(id));
		}

		bs.SetBitIndex(index);
		rules.set(key, bs);
		rules.set_u32(key + "index", index);
	}

	void UpdateEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];

			string key = "_entity" + entity.getId();

			CBitStream bs;
			if (rules.get(key, bs))
			{
				bs.SetBitIndex(rules.get_u32(key + "index"));
				entity.deserialize(bs);
			}
			else
			{
				print("Removed entity: " + entity.getId());
				entities.removeAt(i--);
				rules.set(key, null);
				rules.clear(key + "index");
			}
		}
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
