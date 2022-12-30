#include "Gun.as"

shared Gun@ getGun(u8 type, Actor@ actor)
{
    GunDirector director;

	switch (type)
	{
	case GunType::SMG:
		director.SetGunBuilder(SMGBuilder(actor));
		break;
	}

	return director.getGun();
}

shared enum GunType
{
	SMG
}
