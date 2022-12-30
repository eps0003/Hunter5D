shared class GunDirector
{
	private GunBuilder@ gunBuilder;

	void SetGunBuilder(GunBuilder@ builder)
	{
		@gunBuilder = builder;
	}

	Gun getGun()
	{
		gunBuilder.SetName();
		gunBuilder.SetMagazineSize();
		gunBuilder.SetReadyTime();
		gunBuilder.SetReloadTime();
		gunBuilder.SetFireRate();
		gunBuilder.SetShootHandler();
		gunBuilder.SetAmmoHandler();
		return gunBuilder.build();
	}
}
