#include "LoadStep.as"

shared class ServerLoadStep : LoadStep
{
	ServerLoadStep(string message)
	{
		super(message);
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_f32(progress);
	}

	bool deserialize(CBitStream@ bs)
	{
		if (!bs.saferead_f32(progress)) return false;
		return true;
	}
}
