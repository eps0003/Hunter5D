#include "EntityManager.as"
#include "Utilities.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	Entity::getManager().AddEntity(Entity(getUniqueId()));
}
