#include "Entity.as"
#include "Actor.as"

shared class EntityManager
{
	private Entity@[] entities;
	private dictionary packets;

	private CRules@ rules = getRules();

	Entity@[] getEntities()
	{
		return entities;
	}

	Actor@[] getActors()
	{
		Actor@[] actors;

		for (uint i = 0; i < entities.size(); i++)
		{
			Actor@ actor = cast<Actor>(entities[i]);
			if (actor !is null)
			{
				actors.push_back(actor);
			}
		}

		return actors;
	}

	void AddEntity(Entity@ entity)
	{
		u16 id = entity.getId();
		u8 type = entity.getType();

		if (entityExists(id))
		{
			error("Attempted to add entity with ID already in use: " + type);
			printTrace();
			return;
		}

		Actor@ actor = cast<Actor>(entity);
		if (actor !is null && actorExists(actor.getPlayer()))
		{
			error("Attempted to add actor for player that already has actor: " + actor.getPlayer().getUsername());
			printTrace();
			return;
		}

		entities.push_back(entity);
		print("Added entity: " + id);

		entity.Init();

		if (isServer())
		{
			CBitStream bs;
			bs.write_u8(type);
			entity.SerializeInit(bs);
			rules.SendCommand(rules.getCommandID("create entity"), bs, true);
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
				RemoveEntityAtIndex(i);
				return;
			}
		}

		error("Attempted to remove entity with invalid ID: " + id);
		printTrace();
	}

	void RemoveActor(CPlayer@ player)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Actor@ actor = cast<Actor>(entities[i]);
			if (actor !is null && actor.getPlayer() is player)
			{
				RemoveEntityAtIndex(i);
				return;
			}
		}

		error("Attempted to remove actor for player that doesn't have an actor: " + player.getUsername());
		printTrace();
	}

	private void RemoveEntityAtIndex(uint index)
	{
		Entity@ entity = entities[index];
		u16 id = entity.getId();

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(id);
			rules.SendCommand(rules.getCommandID("remove entity"), bs, true);
		}

		entities.removeAt(index);
		packets.delete("" + id);
		print("Removed entity: " + id);
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

	Actor@ getActor(CPlayer@ player)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			Actor@ actor = cast<Actor>(entities[i]);
			if (actor !is null && actor.getPlayer() is player)
			{
				return actor;
			}
		}
		return null;
	}

	bool entityExists(u16 id)
	{
		return getEntity(id) !is null;
	}

	bool actorExists(CPlayer@ player)
	{
		return getActor(player) !is null;
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

			if (isServer())
			{
				CBitStream bs;
				entity.SerializeTick(bs);
				rules.SendCommand(rules.getCommandID("sync entity"), bs, true);
			}

			Actor@ actor = cast<Actor>(entity);
			if (actor !is null && actor.getPlayer().isMyPlayer() && !isServer())
			{
				CBitStream bs;
				actor.SerializeTickClient(bs);
				rules.SendCommand(rules.getCommandID("sync entity"), bs, true);
			}
		}
	}

	void DeserializeEntity(CBitStream@ bs)
	{
		CBitStream bs2;
		bs2.writeBitStream(bs, bs.getBitIndex(), bs.getBitsUsed() - bs.getBitIndex());
		bs2.ResetBitIndex();

		u16 id;
		if (!bs.saferead_u16(id)) return;

		packets.set("" + id, bs2);
	}

	void UpdateEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			entities[i].PreUpdate();
		}

		for (uint i = 0; i < entities.size(); i++)
		{
			Entity@ entity = entities[i];

			if (!isServer())
			{
				CBitStream@ bs;
				if (packets.get("" + entity.getId(), @bs))
				{
					bs.ResetBitIndex();
					entity.deserializeTick(bs);
				}
			}

			Actor@ actor = cast<Actor>(entity);
			if (actor !is null && !actor.getPlayer().isMyPlayer())
			{
				CBitStream@ bs;
				if (packets.get("" + actor.getId(), @bs))
				{
					bs.ResetBitIndex();
					actor.deserializeTickClient(bs);
				}
			}

			entity.Update();
		}

		for (uint i = 0; i < entities.size(); i++)
		{
			entities[i].PostUpdate();
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
