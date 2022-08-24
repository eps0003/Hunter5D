#include "PhysicalActor.as"
#include "Utilities.as"

#define SERVER_ONLY

const Vec3f SPAWN_POSITION = Vec3f(4, 10, 4);

EntityManager@ entityManager;

void onRestart(CRules@ this)
{
	this.RemoveScript(getCurrentScriptName());
}

void onInit(CRules@ this)
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

void SpawnPlayer(CPlayer@ player, Vec3f position)
{
	entityManager.AddEntity(PhysicalActor(getUniqueId(), player, position));
}
