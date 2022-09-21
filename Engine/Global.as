Driver@ driver;

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
	if (isClient())
	{
		@driver = getDriver();
	}

	this.set("mouse", null);

	this.set("entity manager", null);
	this.set("loading manager", null);

	// TODO: Move 3D-specific resets out of engine
	this.set("map", null);
	this.set("map syncer server", null);
	this.set("map syncer client", null);
	this.set("map renderer", null);
}

void onRender(CRules@ this)
{
	GUI::DrawRectangle(Vec2f_zero, driver.getScreenDimensions(), color_black);
}