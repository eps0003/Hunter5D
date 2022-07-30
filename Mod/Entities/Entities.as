#include "Entity1.as"
#include "Entity2.as"
#include "Actor1.as"

shared Entity@ getEntity(u8 type)
{
	switch (type)
	{
	case 0:
		return Entity1();
	case 1:
		return Entity2();
	case 2:
		return Actor1();
	}
	return null;
}
