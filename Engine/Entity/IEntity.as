#include "ISerializable.as"

shared interface IEntity : ISerializable
{
	u16 getId();
	u8 getType();
	string getName();

	void Init();
	void PreUpdate();
	void Update();
	void PostUpdate();
	void Render();
	void Draw();
}
