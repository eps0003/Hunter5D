#include "Entity.as"

EntityManager@ entityManager;

void onInit(CRules@ this)
{
	this.addCommandID("create entity");
	this.addCommandID("sync entity");
	this.addCommandID("remove entity");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();
}

void onTick(CRules@ this)
{
	if (!isClient() && getPlayerCount() > 0)
	{
		entityManager.SyncEntities();
	}

	if (!isServer())
	{
		entityManager.UpdateEntities();
	}
}

void onRender(CRules@ this)
{
	entityManager.RenderEntities();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Entity@[] entities = entityManager.getEntites();
	for (uint i = 0; i < entities.size(); i++)
	{
		Entity@ entity = entities[i];

		CBitStream bs;
		bs.write_u16(entity.getId());
		bs.write_u8(entity.getType());
		entity.Serialize(bs);
		this.SendCommand(this.getCommandID("create entity"), bs, player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("sync entity"))
	{
		entityManager.DeserializeEntity(params);
	}
	else if (!isServer() && cmd == this.getCommandID("remove entity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		entityManager.RemoveEntity(id);
	}
}
