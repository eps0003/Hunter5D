#include "SandboxActor.as"
#include "SpectatorActor.as"
#include "Utilities.as"

#define SERVER_ONLY

IActorManager@ actorManager;
Map@ map;

void onRestart(CRules@ this)
{
	this.RemoveScript(getCurrentScriptName());
}

void onInit(CRules@ this)
{
	@actorManager = Actor::getManager();
	@map = Map::getMap();
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newTeam)
{
	u8 currentTeam = player.getTeamNum();
	if (currentTeam != newTeam)
	{
		player.server_setTeamNum(newTeam);
		SpawnPlayer(this, player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (Command::equals(cmd, "player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		SpawnPlayer(this, player);
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	SpawnPlayer(this, victim);
}

void SpawnPlayer(CRules@ this, CPlayer@ player)
{
	Vec3f position = map.dimensions * Vec3f(0.5f, 1.0f, 0.5f);

	if (actorManager.actorExists(player))
	{
		actorManager.RemoveActor(player);
	}

	IActor@ actor;
	if (player.getTeamNum() == this.getSpectatorTeamNum())
	{
		@actor = SpectatorActor(getUniqueId(), player, position);
	}
	else
	{
		@actor = SandboxActor(getUniqueId(), player, position);
	}

	actorManager.AddActor(actor);
}