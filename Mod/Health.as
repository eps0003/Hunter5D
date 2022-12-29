#include "Serializable.as"

shared class Health : Serializable
{
	private u8 maxHealth;
	private u8 health;

	Health()
	{
		maxHealth = 255;
		health = maxHealth;
	}

	Health(u8 maxHealth)
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

	float getHealthPercentage()
	{
		return maxHealth > 0 ? health / float(maxHealth) : 0.0f;
	}

	void SetHealth(u8 health)
	{
		this.health = Maths::Clamp(health, 0, maxHealth);
	}

	void SetMaxHealth()
	{
		SetHealth(maxHealth);
	}

	void AddHealth(u8 health)
	{
		SetHealth(this.health + health);
	}

	bool hasNoHealth()
	{
		return health == 0;
	}

	bool hasFullHealth()
	{
		return health >= maxHealth;
	}

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_u8(maxHealth);
		bs.write_u8(health);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		return bs.saferead_u8(maxHealth) && bs.saferead_u8(health);
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
