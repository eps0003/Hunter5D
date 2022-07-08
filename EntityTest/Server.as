#include "EntityManager.as"

EntityManager@ entityManager;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();
}

void onTick(CRules@ this)
{
	entityManager.SyncEntities();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync entities"))
	{
		entityManager.DeserializeEntities(params);
	}
}
