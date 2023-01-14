#include "IEntityManager.as"
#include "PhysicsHandler.as"

shared class EntityManager : IEntityManager
{
	private IEntity@[]@ entities;
	private dictionary packets;

	private IPhysicsHandler@ physicsHandler;
	private CRules@ rules = getRules();

	EntityManager(IEntity@[]@ entities)
	{
		@this.entities = entities;
		@physicsHandler = PhysicsHandler();
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

			// Physics
			IPhysics@ physicsEntity = cast<IPhysics>(entity);
			if (physicsEntity !is null)
			{
				physicsHandler.Update(physicsEntity);
			}
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
			IEntity@[]@ entities;
			getRules().get("entities", @entities);

			@manager = EntityManager(entities);
			getRules().set("entity manager", @manager);
		}
		return manager;
	}
}
