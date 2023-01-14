#include "IActorManager.as"
#include "IEntity.as"

shared class ActorManager : IActorManager
{
	private IEntity@[]@ entities;

	ActorManager(IEntity@[]@ entities)
	{
		@this.entities = entities;
	}

	IActor@[] getActors()
	{
		IActor@[] actors;

		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
			if (actor is null) continue;

			actors.push_back(actor);
		}

		return actors;
	}

	IActor@ getActor(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
			if (actor is null) continue;

			if (actor.getId() == id)
			{
				return actor;
			}
		}
		return null;
	}

	IActor@ getActor(CPlayer@ player)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
			if (actor is null) continue;

			if (actor.getPlayer() is player)
			{
				return actor;
			}
		}
		return null;
	}

	void AddActor(IActor@ actor)
	{
		u16 id = actor.getId();
		u8 type = actor.getType();
		CPlayer@ player = actor.getPlayer();

		if (actorExists(id))
		{
			error("Attempted to add entity with ID already in use: " + id);
			printTrace();
			return;
		}

		if (actorExists(player))
		{
			error("Attempted to add actor for player that already has actor: " + player.getUsername());
			printTrace();
			return;
		}

		entities.push_back(actor);
		print("Added actor: " + actor.getName());

		actor.Init();

		if (isServer())
		{
			CBitStream bs;
			bs.write_u8(type);
			actor.SerializeInit(bs);
			Command::Send("create entity", bs, true);
		}
	}

	void RemoveActor(IActor@ actor)
	{
		RemoveActor(actor.getId());
	}

	void RemoveActor(CPlayer@ player)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
			if (actor is null) continue;

			if (actor.getPlayer() is player)
			{
				RemoveActorAtIndex(i);
				return;
			}
		}

		error("Attempted to remove actor for player that does not have actor: " + player.getUsername());
		printTrace();
	}

	void RemoveActor(u16 id)
	{
		for (uint i = 0; i < entities.size(); i++)
		{
			IActor@ actor = cast<IActor>(entities[i]);
			if (actor is null) continue;

			if (actor.getId() == id)
			{
				RemoveActorAtIndex(i);
				return;
			}
		}

		error("Attempted to remove actor with invalid ID: " + id);
		printTrace();
	}

	private void RemoveActorAtIndex(uint index)
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
		print("Removed actor: " + entity.getName());
	}

	bool actorExists(u16 id)
	{
		return getActor(id) !is null;
	}

	bool actorExists(CPlayer@ player)
	{
		return getActor(player) !is null;
	}

	uint getActorCount()
	{
		return getActors().size();
	}
}

namespace Actor
{
	shared IActorManager@ getManager()
	{
		IActorManager@ manager;
		if (!getRules().get("actor manager", @manager))
		{
			IEntity@[]@ entities;
			getRules().get("entities", @entities);

			@manager = ActorManager(entities);
			getRules().set("actor manager", @manager);
		}
		return manager;
	}
}
