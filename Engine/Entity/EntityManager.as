#include "Entity.as"
#include "Actor.as"

shared class EntityManager
{
	private IEntity@[] entities;
	private dictionary packets;

	private CRules@ rules = getRules();

	IEntity@[] getEntities()
	{
		return entities;
	}

	IActor@[] getActors()
	{
		IActor@[] actors;

		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
			if (actor !is null)
			{
				actors.push_back(actor);
			}
		}

		return actors;
	}

	void AddEntity(IEntity@ entity)
	{
		u16 id = entity.getId();
		u8 type = entity.getType();

		if (entityExists(id))
		{
			error("Attempted to add entity with ID already in use: " + type);
			printTrace();
			return;
		}

		IActor@ actor = cast<IActor>(entity);
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

	void RemoveActor(CPlayer@ player)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
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
		IEntity@ entity = entities[index];
		u16 id = entity.getId();

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(id);
			Command::Send("remove entity", bs, true);
		}

		entities.removeAt(index);
		packets.delete("entity" + id);
		packets.delete("actor" + id);
		print("Removed entity: " + id);
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

	IActor@ getActor(CPlayer@ player)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
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
			IEntity@ entity = entities[i];

			if (isServer())
			{
				CBitStream bs;
				entity.SerializeTick(bs);
				Command::Send("sync entity", bs, true);
			}

			IActor@ actor = cast<IActor>(entity);
			if (actor !is null && actor.isMyActor() && !isServer())
			{
				CBitStream bs;
				actor.SerializeTickClient(bs);
				Command::Send("sync actor", bs, true);
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

		packets.set("entity" + id, bs2);
	}

	void DeserializeActor(CBitStream@ bs)
	{
		CBitStream bs2;
		bs2.writeBitStream(bs, bs.getBitIndex(), bs.getBitsUsed() - bs.getBitIndex());
		bs2.ResetBitIndex();

		u16 id;
		if (!bs.saferead_u16(id)) return;

		packets.set("actor" + id, bs2);
	}

	void UpdateEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			entities[i].PreUpdate();
		}

		for (uint i = 0; i < entities.size(); i++)
		{
			IEntity@ entity = entities[i];

			if (!isServer())
			{
				CBitStream@ bs;
				if (packets.get("entity" + entity.getId(), @bs))
				{
					bs.ResetBitIndex();
					entity.deserializeTick(bs);
				}
			}

			IActor@ actor = cast<IActor>(entity);
			if (actor !is null && !actor.isMyActor())
			{
				CBitStream@ bs;
				if (packets.get("actor" + actor.getId(), @bs))
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

	void DrawEntities()
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			entities[i].Draw();
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
