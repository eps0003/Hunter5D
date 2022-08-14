void onInit(CRules@ this)
{
	onRestart(this);
	getSecurity().reloadSecurity();
	CFileImage::silent_errors = true;
	GUI::SetFont("menu");

	if (isServer())
	{
		sv_mapautocycle = true;
	}
}

void onRestart(CRules@ this)
{
	this.set("entity manager", null);
	this.set("loading manager", null);

	// TODO: Move 3D-specific resets out of engine
	this.set("map", null);
	this.set("map syncer", null);
}
