#include "Entity.as"
#include "Entities.as"

EntityManager@ entityManager;

void onInit(CRules@ this)
{
	this.addCommandID("create entity");
	this.addCommandID("sync entity");
	this.addCommandID("sync actor");
	this.addCommandID("remove entity");

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

void onRender(CRules@ this)
{
	if (entityManager !is null)
	{
		entityManager.RenderEntities();
	}
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
		this.SendCommand(this.getCommandID("create entity"), bs, player);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		entityManager.RemoveActor(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("create entity"))
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
	else if (!isServer() && cmd == this.getCommandID("sync entity"))
	{
		entityManager.DeserializeEntity(params);
	}
	else if (cmd == this.getCommandID("sync actor"))
	{
		entityManager.DeserializeActor(params);
	}
	else if (!isServer() && cmd == this.getCommandID("remove entity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		entityManager.RemoveEntity(id);
	}
}
