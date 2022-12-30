shared class ShootAction
{
	private Gun@ gun;
	private Actor@ actor;

	ShootAction(Gun@ gun, Actor@ actor)
	{
		@this.gun = gun;
		@this.actor = actor;
	}

	void Shoot()
	{
		gun.Shoot();
	}

	bool canShoot()
	{
		CBlob@ blob = actor.getBlob();
		bool keyIsPressed = gun.isAutomatic()
			? blob.isKeyPressed(key_action1)
			: blob.isKeyJustPressed(key_action1);
		return gun.canShoot() && keyIsPressed;
	}
}

shared class ReloadAction
{
	private Gun@ gun;

	ReloadAction(Gun@ gun)
	{
		@this.gun = gun;
	}

	void Reload()
	{
		gun.Reload();
	}

	bool canReload()
	{
		return gun.canReload() && getControls().isKeyPressed(KEY_KEY_R);
	}

	bool canCancelReload()
	{
		return !gun.isMagazineFed();
	}

	bool reloadsIncrementally()
	{
		return !gun.isMagazineFed();
	}

	bool hasFinishedReloading()
	{
		return gun.hasFullClip() || !gun.hasReserveAmmo();
	}
}
