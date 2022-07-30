shared u16 getUniqueId()
{
	return getRules().add_u16("_id", 1);
}

shared bool saferead_player(CBitStream@ bs, CPlayer@ &out player)
{
	u16 id;
	if (!bs.saferead_netid(id)) return false;

	@player = getPlayerByNetworkId(id);
	return player !is null;
}

shared bool isLocalHost()
{
	return isClient() && isServer();
}

shared bool isTickPaused()
{
	return isLocalHost() && Menu::getMainMenu() !is null;
}

shared int getFPS()
{
	return getRules().get_u32("fps");
}
