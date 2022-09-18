#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			CreateHusk(player);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	player.server_setTeamNum(0);
	CreateHusk(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	RemoveHusk(player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	CreateHusk(victim);
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldTeam, u8 newTeam)
{
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		blob.server_setTeamNum(newTeam);
	}
}

void CreateHusk(CPlayer@ player)
{
	CBlob@ blob = server_CreateBlob("husk");
	if (blob !is null)
	{
		blob.server_SetPlayer(player);
		print("Created husk for " + player.getUsername());
	}
}

void RemoveHusk(CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		blob.server_Die();
		print("Removed husk for " + player.getUsername());
	}
}
