shared interface GunBuilder
{
	void SetType();
	void SetName();
	void SetMagazineSize();
	void SetReadyTime();
	void SetReloadTime();
	void SetFireRate();
	void SetShootHandler();
	void SetAmmoHandler();
	Gun build();
}

shared class SMGBuilder : GunBuilder
{
	private Gun@ gun;

	SMGBuilder(IActor@ actor)
	{
		@gun = Gun(actor);
	}

	void SetType()
	{
		gun.type = GunType::SMG;
	}

	void SetName()
	{
		gun.name = "SMG";
	}

	void SetMagazineSize()
	{
		gun.magazineSize = 24;
	}

	void SetReadyTime()
	{
		gun.readyTimeSeconds = 0.3f;
	}

	void SetReloadTime()
	{
		gun.reloadTimeSeconds = 1.0f;
	}

	void SetFireRate()
	{
		gun.fireRateSeconds = 0.1f;
	}

	void SetShootHandler()
	{
		@gun.shootHandler = AutomaticShootHandler(gun);
	}

	void SetAmmoHandler()
	{
		@gun.ammoHandler = MagazineAmmoHandler(gun);
	}

	Gun build()
	{
		return gun;
	}
}
