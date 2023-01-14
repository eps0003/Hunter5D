#include "IEntity.as"

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
	if (isServer())
	{
		this.add_u8("game index", 1);
		this.Sync("game index", true);
	}

	this.set("mouse", null);

	this.set("entities", array<IEntity@>());
	this.set("entity manager", null);
	this.set("actor manager", null);

	this.set("loading manager", null);

	// TODO: Move 3D-specific resets out of engine
	this.set("map", null);
	this.set("map syncer server", null);
	this.set("map syncer client", null);
	this.set("map renderer", null);
}
