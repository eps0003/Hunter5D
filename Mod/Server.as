#include "SandboxActor.as"
#include "SpectatorActor.as"
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
		SpawnPlayer(this, player, SPAWN_POSITION);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		SpawnPlayer(this, player, SPAWN_POSITION);
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	SpawnPlayer(this, victim, SPAWN_POSITION);
}

void SpawnPlayer(CRules@ this, CPlayer@ player, Vec3f position)
{
	if (entityManager.actorExists(player))
	{
		entityManager.RemoveActor(player);
	}

	Actor@ actor;
	if (player.getTeamNum() == this.getSpectatorTeamNum())
	{
		@actor = SpectatorActor(getUniqueId(), player, position);
	}
	else
	{
		@actor = SandboxActor(getUniqueId(), player, position);
	}

	entityManager.AddEntity(actor);
}