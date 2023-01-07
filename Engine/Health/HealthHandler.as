#include "IHealthHandler.as"

shared class HealthHandler : IHealthHandler
{
	private u8 maxHealth;
	private u8 health;

	HealthHandler()
	{
		maxHealth = 255;
		health = maxHealth;
	}

	HealthHandler(u8 maxHealth)
	{
		this.maxHealth = maxHealth;
		this.health = maxHealth;
	}

	u8 getHealth()
	{
		return health;
	}

	u8 getMaxHealth()
	{
		return maxHealth;
	}

	void SetHealth(u8 health)
	{
		this.health = Maths::Clamp(health, 0, maxHealth);
	}

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_u8(health);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return bs.saferead_u8(health);
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u8(health);
	}

	bool deserializeTick(CBitStream@ bs)
	{
		return bs.saferead_u8(health);
	}
}
