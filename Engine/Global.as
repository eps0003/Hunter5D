void onInit(CRules@ this)
{
	onRestart(this);
	getSecurity().reloadSecurity();
	CFileImage::silent_errors = true;
	GUI::SetFont("menu");
}

void onRestart(CRules@ this)
{
	this.set("entity manager", null);
}
