#include "IActor.as"

shared interface IActorManager
{
	IActor@[] getActors();

	IActor@ getActor(u16 id);
	IActor@ getActor(CPlayer@ player);

	void AddActor(IActor@ actor);

	void RemoveActor(IActor@ actor);
	void RemoveActor(u16 id);
	void RemoveActor(CPlayer@ player);

	bool actorExists(u16 id);
	bool actorExists(CPlayer@ player);

	uint getActorCount();
}
