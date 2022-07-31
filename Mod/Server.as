#include "Entity1.as"
#include "Entity2.as"
#include "Actor1.as"
#include "Utilities.as"

#define SERVER_ONLY

const Vec2f SPAWN_POSITION = Vec2f(100, 200);

EntityManager@ entityManager;

u16 id = 0;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@entityManager = Entity::getManager();

	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			SpawnPlayer(player, SPAWN_POSITION);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	SpawnPlayer(player, SPAWN_POSITION);
}

void onTick(CRules@ this)
{
	if (getGameTime() == 1)
	{
		// entityManager.AddEntity(Entity1(id = getUniqueId(), 1));
		// entityManager.AddEntity(Entity2(getUniqueId(), "hello world"));
	}

	// if (!entityManager.entityExists(id)) return;

	// CPlayer@ me = getPlayerByUsername("epsilon");
	// if (me is null) return;

	// CBlob@ blob = me.getBlob();
	// if (blob is null) return;

	// if (blob.isKeyJustPressed(key_action3))
	// {
	// 	entityManager.RemoveEntity(id);
	// }
}

void SpawnPlayer(CPlayer@ player, Vec2f position)
{
	entityManager.AddEntity(Actor1(getUniqueId(), player, position));
}
