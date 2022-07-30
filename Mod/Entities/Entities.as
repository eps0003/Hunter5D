#include "Entity1.as"
#include "Entity2.as"
#include "Actor1.as"

shared Entity@ getEntity(u16 id, u8 type)
{
	switch (type)
	{
	case 0:
		return Entity1(id);
	case 1:
		return Entity2(id);
	case 2:
		return Actor1(id);
	}
	return null;
}
