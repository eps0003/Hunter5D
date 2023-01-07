#include "ISerializable.as"

shared interface IEntity : ISerializable
{
	u16 getId();
	u8 getType();

	void Init();
	void PreUpdate();
	void Update();
	void PostUpdate();
	void Render();
	void Draw();
}
