#include "ISerializable.as"

shared interface IHealthHandler : ISerializable
{
	u8 getHealth();
	u8 getMaxHealth();
	void SetHealth(u8 health);
}
