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
			u16 entityId = entities[i].getId();
			if (entityId == id)
			{
				CBitStream bs;
				bs.write_u16(entityId);
				bs.write_bool(false);
				rules.SendCommand(rules.getCommandID("sync entity"), bs, true);

				entities.removeAt(i);
				print("Removed entity: " + entityId);
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
			Entity@ entity = entities[i];

			CBitStream bs;
			bs.write_u16(entity.getId());
			bs.write_bool(true);
			entity.Serialize(bs);
			rules.SendCommand(rules.getCommandID("sync entity"), bs, true);
		}
	}

	void DeserializeEntity(CBitStream@ bs)
	{
		uint index = bs.getBitIndex();

		u16 id;
		if (!bs.saferead_u16(id)) return;

		bool alive;
		if (!bs.saferead_bool(alive)) return;

		if (alive)
		{
			string key = "_entity" + id;
			if (!rules.exists(key))
			{
				AddEntity(Entity(id));
			}

			bs.SetBitIndex(index);
			rules.set(key, bs);
			rules.set_u32(key + "index", index);
		}
		else
		{
			RemoveEntity(id);
		}
	}

	void UpdateEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];

			string key = "_entity" + entity.getId();

			CBitStream bs;
			if (!rules.get(key, bs)) continue;

			bs.SetBitIndex(rules.get_u32(key + "index"));
			entity.deserialize(bs);
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
