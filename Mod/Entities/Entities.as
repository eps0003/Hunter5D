#include "Entity1.as"
#include "Entity2.as"
#include "Actor1.as"

shared Entity@ getEntity(u8 type)
{
	switch (type)
	{
	case EntityType::Entity1:
		return Entity1();
	case EntityType::Entity2:
		return Entity2();
	case EntityType::Actor1:
		return Actor1();
	}
	return null;
}

shared enum EntityType
{
	Entity1,
	Entity2,
	Actor1
}
