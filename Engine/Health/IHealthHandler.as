#include "Serializable.as"

shared interface IHealthHandler : Serializable
{
	u8 getHealth();
	u8 getMaxHealth();
	void SetHealth(u8 health);
}
