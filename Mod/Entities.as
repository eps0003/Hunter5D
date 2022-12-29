#include "SpectatorActor.as"
#include "PhysicalActor.as"
#include "SandboxActor.as"
#include "HunterActor.as"

shared Entity@ getEntity(u8 type)
{
	switch (type)
	{
	case EntityType::SpectatorActor:
		return SpectatorActor();
	case EntityType::PhysicalActor:
		return PhysicalActor();
	case EntityType::SandboxActor:
		return SandboxActor();
	case EntityType::HunterActor:
		return HunterActor();
	}
	return null;
}

shared enum EntityType
{
	SpectatorActor,
	PhysicalActor,
	SandboxActor,
	HunterActor
}
