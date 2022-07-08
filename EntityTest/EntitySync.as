#include "EntityManager.as"
#include "Utilities.as"

EntityManager@ entityManager;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();

	if (isServer())
	{
		entityManager.AddEntity(Entity(getUniqueId()));
	}
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

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("sync entity"))
	{
		entityManager.DeserializeEntity(params);
	}
}
