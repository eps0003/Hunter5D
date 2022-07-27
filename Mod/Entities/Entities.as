#include "Entity1.as"
#include "Entity2.as"

shared Entity@ getEntity(u16 id, u8 type)
{
	switch (type)
	{
	case 0:
		return Entity1(id);
	case 1:
		return Entity2(id);
	}
	return null;
}
