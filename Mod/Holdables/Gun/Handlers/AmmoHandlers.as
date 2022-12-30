shared interface AmmoHandler
{
	void Reload();
	bool canReload();
	bool canCancelReload();
	bool hasFinishedReloading();
	bool isReloadKeyPressed();
	uint getReloadTime();
	uint getAmmo();
	uint getReserveAmmo();
	void SetAmmo(uint ammo);
	void SetReserveAmmo(uint ammo);
}

shared class MagazineAmmoHandler : AmmoHandler
{
	private Gun@ gun;
	private uint ammo;
	private uint reserveAmmo;

	MagazineAmmoHandler(Gun@ gun)
	{
		@this.gun = gun;

		ammo = gun.magazineSize;
		reserveAmmo = gun.magazineSize * 2;
	}

	void Reload()
	{
		int ammoToReload = Maths::Min(getMagazineSize() - getAmmo(), getReserveAmmo());
		SetAmmo(getAmmo() + ammoToReload);
		SetReserveAmmo(getReserveAmmo() - ammoToReload);
	}

	bool canReload()
	{
		return getAmmo() < getMagazineSize() && getReserveAmmo() > 0;
	}

	bool canCancelReload()
	{
		return false;
	}

	bool hasFinishedReloading()
	{
		return getAmmo() >= getMagazineSize() || getReserveAmmo() == 0;
	}

	bool isReloadKeyPressed()
	{
		return getControls().isKeyPressed(KEY_KEY_R);
	}

	uint getReloadTime()
	{
		return Maths::Ceil(gun.reloadTimeSeconds * getTicksASecond());
	}

	uint getMagazineSize()
	{
		return gun.magazineSize;
	}

	uint getAmmo()
	{
		return ammo;
	}

	uint getReserveAmmo()
	{
		return reserveAmmo;
	}

	void SetAmmo(uint ammo)
	{
		this.ammo = ammo;
	}

	void SetReserveAmmo(uint ammo)
	{
		this.reserveAmmo = ammo;
	}
}
