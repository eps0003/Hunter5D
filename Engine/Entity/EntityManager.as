#include "Entity.as"
#include "Actor.as"

shared class EntityManager
{
	private Entity@[] entities;

	private CRules@ rules = getRules();

	Entity@[] getEntities()
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
				entity.SerializeInit(bs);
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
				bs.write_u16(id);
				rules.SendCommand(rules.getCommandID("remove entity"), bs, true);

				entities.removeAt(i);
				print("Removed entity: " + id);

				string key = "_entity" + id;
				rules.set(key, null);

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

			if (!isClient())
			{
				CBitStream bs;
				bs.write_u16(entity.getId());
				entity.SerializeTick(bs);
				rules.SendCommand(rules.getCommandID("sync entity"), bs, true);
			}

			Actor@ actor = cast<Actor@>(entity);
			if (actor !is null && actor.getPlayer().isMyPlayer())
			{
				CBitStream bs;
				bs.write_u16(entity.getId());
				actor.SerializeTickClient(bs);
				rules.SendCommand(rules.getCommandID("sync actor"), bs, true);
			}
		}
	}

	void DeserializeEntity(CBitStream@ bs)
	{
		u16 id;
		if (!bs.saferead_u16(id)) return;

		string key = "_entity" + id;
		uint index = bs.getBitIndex();

		bs.SetBitIndex(index);
		rules.set(key, bs);
		rules.set_u32(key + "index", index);
	}

	void DeserializeActor(CBitStream@ bs)
	{
		u16 id;
		if (!bs.saferead_u16(id)) return;

		string key = "_actor" + id;
		uint index = bs.getBitIndex();

		bs.SetBitIndex(index);
		rules.set(key, bs);
		rules.set_u32(key + "index", index);
	}

	void UpdateEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];

			if (!isServer())
			{
				string key = "_entity" + entity.getId();

				CBitStream bs;
				if (rules.get(key, bs))
				{
					bs.SetBitIndex(rules.get_u32(key + "index"));
					entity.deserializeTick(bs);
				}
			}

			Actor@ actor = cast<Actor@>(entity);
			if (actor !is null && !actor.getPlayer().isMyPlayer())
			{
				string key = "_actor" + actor.getId();

				CBitStream bs;
				if (rules.get(key, bs))
				{
					bs.SetBitIndex(rules.get_u32(key + "index"));
					actor.deserializeTickClient(bs);
				}
			}
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
