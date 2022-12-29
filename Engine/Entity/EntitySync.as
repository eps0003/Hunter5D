#include "Entity.as"
#include "Entities.as"

EntityManager@ entityManager;

void onInit(CRules@ this)
{
	Command::Add("create entity");
	Command::Add("sync entity");
	Command::Add("sync actor");
	Command::Add("remove entity");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();
}

void onTick(CRules@ this)
{
	if (getPlayerCount() > 0)
	{
		entityManager.SyncEntities();
	}

	entityManager.UpdateEntities();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Entity@[] entities = entityManager.getEntities();
	for (uint i = 0; i < entities.size(); i++)
	{
		Entity@ entity = entities[i];

		CBitStream bs;
		bs.write_u8(entity.getType());
		entity.SerializeInit(bs);
		Command::Send("create entity", bs, player);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer() && entityManager.actorExists(player))
	{
		entityManager.RemoveActor(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && Command::equals(cmd, "create entity"))
	{
		u8 type;
		if (!params.saferead_u8(type)) return;

		Entity@ entity = getEntity(type);
		if (entity is null)
		{
			error("Attempted to create entity with invalid type: " + type);
			return;
		}

		if (!entity.deserializeInit(params)) return;

		entityManager.AddEntity(entity);
	}
	else if (!isServer() && Command::equals(cmd, "sync entity"))
	{
		entityManager.DeserializeEntity(params);
	}
	else if (Command::equals(cmd, "sync actor"))
	{
		entityManager.DeserializeActor(params);
	}
	else if (!isServer() && Command::equals(cmd, "remove entity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		entityManager.RemoveEntity(id);
	}
}
