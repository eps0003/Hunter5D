#include "Entity1.as"

shared class EntityManager
{
	private Entity@[] entities;

	private CRules@ rules = getRules();

	Entity@[] getEntites()
	{
		return entities;
	}

	void AddEntity(Entity@ entity)
	{
		u16 id = entity.getId();
		u8 type = entity.getType();

		if (!entityExists(id))
		{
			entities.push_back(entity);
			print("Added entity: " + id);

			if (!isClient())
			{
				CBitStream bs;
				bs.write_u16(id);
				bs.write_u8(type);
				rules.SendCommand(rules.getCommandID("create entity"), bs, true);
			}
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
				rules.SendCommand(rules.getCommandID("remove entity"), bs, true);

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
			entity.Serialize(bs);
			rules.SendCommand(rules.getCommandID("sync entity"), bs, true);
		}
	}

	void DeserializeEntity(CBitStream@ bs)
	{
		uint index = bs.getBitIndex();

		u16 id;
		if (!bs.saferead_u16(id)) return;

		string key = "_entity" + id;
		if (!rules.exists(key)) return;

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
			if (!rules.get(key, bs)) continue;

			bs.SetBitIndex(rules.get_u32(key + "index"));
			entity.deserialize(bs);
		}
	}

	void RenderEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			entities[i].Render();
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
