string prevMapName;

void onInit(CRules@ this)
{
	prevMapName = getMap().getMapName();
}

void onRestart(CRules@ this)
{
	string mapName = getMap().getMapName();
	this.set_bool("nextmap", mapName != prevMapName);
	prevMapName = mapName;
}
