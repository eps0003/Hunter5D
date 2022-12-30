shared interface ShootHandler
{
	void Shoot();
	bool canShoot();
	bool isShootKeyPressed();
	uint getFireRate();
}

shared class AutomaticShootHandler : ShootHandler
{
	private Gun@ gun;

	AutomaticShootHandler(Gun@ gun)
	{
		@this.gun = gun;
	}

	void Shoot()
	{
		uint currentAmmo = gun.ammoHandler.getAmmo();
		if (currentAmmo > 0)
		{
			gun.ammoHandler.SetAmmo(currentAmmo - 1);
		}
	}

	bool canShoot()
	{
		return gun.ammoHandler.getAmmo() > 0;
	}

	bool isShootKeyPressed()
	{
		return gun.actor.getBlob().isKeyPressed(key_action1);
	}

	uint getFireRate()
	{
		return Maths::Ceil(gun.fireRateSeconds * getTicksASecond());
	}
}

shared class ManualShootHandler : ShootHandler
{
	private Gun@ gun;

	ManualShootHandler(Gun@ gun)
	{
		@this.gun = gun;
	}

	void Shoot()
	{
		uint currentAmmo = gun.ammoHandler.getAmmo();
		if (currentAmmo > 0)
		{
			gun.ammoHandler.SetAmmo(currentAmmo - 1);
		}
	}

	bool canShoot()
	{
		return gun.ammoHandler.getAmmo() > 0;
	}

	bool isShootKeyPressed()
	{
		return gun.actor.getBlob().isKeyJustPressed(key_action1);
	}

	uint getFireRate()
	{
		return Maths::Ceil(gun.fireRateSeconds * getTicksASecond());
	}
}
