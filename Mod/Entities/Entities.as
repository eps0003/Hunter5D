#include "Entity1.as"
#include "Entity2.as"
#include "SpectatorActor.as"
#include "PhysicalActor.as"

shared Entity@ getEntity(u8 type)
{
	switch (type)
	{
	case EntityType::Entity1:
		return Entity1();
	case EntityType::Entity2:
		return Entity2();
	case EntityType::SpectatorActor:
		return SpectatorActor();
	case EntityType::PhysicalActor:
		return PhysicalActor();
	}
	return null;
}

shared enum EntityType
{
	Entity1,
	Entity2,
	SpectatorActor,
	PhysicalActor
}
