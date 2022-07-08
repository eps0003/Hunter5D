void onInit(CRules@ this)
{
	this.addCommandID("sync entity");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.set("entity manager", null);
}
