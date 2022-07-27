#include "Entity.as"
#include "Entities.as"

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
	if (isServer()) return;

	if (cmd == this.getCommandID("create entity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		u8 type;
		if (!params.saferead_u8(type)) return;

		Entity@ entity = getEntity(id, type);
		if (entity is null)
		{
			error("Attempted to create entity with invalid type: " + type);
			return;
		}

		if (!entity.deserialize(params)) return;

		Entity::getManager().AddEntity(entity);
	}
	else if (cmd == this.getCommandID("sync entity"))
	{
		entityManager.DeserializeEntity(params);
	}
	else if (cmd == this.getCommandID("remove entity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		entityManager.RemoveEntity(id);
	}
}
