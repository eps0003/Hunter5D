#include "Entity.as"
#include "Utilities.as"

#define SERVER_ONLY

EntityManager@ entityManager;

u16 id = 0;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();
	entityManager.AddEntity(Entity(id = getUniqueId()));
}

void onTick(CRules@ this)
{
	CPlayer@ me = getPlayerByUsername("epsilon");
	if (me is null) return;

	CBlob@ blob = me.getBlob();
	if (blob is null) return;

	if (blob.isKeyJustPressed(key_action3))
	{
		entityManager.RemoveEntity(id);
	}
}
