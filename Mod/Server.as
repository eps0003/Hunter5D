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
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newTeam)
{
	u8 currentTeam = player.getTeamNum();
	if (currentTeam != newTeam)
	{
		player.server_setTeamNum(newTeam);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		SpawnPlayer(player, SPAWN_POSITION);
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	SpawnPlayer(victim, SPAWN_POSITION);
}

void SpawnPlayer(CPlayer@ player, Vec3f position)
{
	if (entityManager.actorExists(player))
	{
		entityManager.RemoveActor(player);
	}

}