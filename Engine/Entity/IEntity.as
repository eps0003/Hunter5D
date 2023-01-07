#include "Serializable.as"

shared interface IEntity : Serializable
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
